package com._Jhin.Backend.Service;

import com._Jhin.Backend.dto.AdicionarPessoaProjetoRequest;
import com._Jhin.Backend.model.Pessoa;
import com._Jhin.Backend.model.PessoaProjeto;
import com._Jhin.Backend.repository.PessoaProjetoRepository;
import com._Jhin.Backend.repository.PessoaRepository;
import com._Jhin.Backend.repository.ProjetoRepository;

import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class PessoaProjetoService {

    private final PessoaProjetoRepository repository;
    private final PessoaRepository pessoaRepository;
    private final ProjetoRepository projetoRepository;

public PessoaProjetoService(
        PessoaProjetoRepository repository,
        PessoaRepository pessoaRepository,
        ProjetoRepository projetoRepository) {

    this.repository = repository;
    this.pessoaRepository = pessoaRepository;
    this.projetoRepository = projetoRepository;
}

    public PessoaProjeto salvar(PessoaProjeto pessoaProjeto) {
        if (pessoaProjeto.getPessoa() == null) {
            throw new RuntimeException("Pessoa necessaria");
        }

        if (pessoaProjeto.getProjeto() == null) {
            throw new RuntimeException("Projeto necessaria");
        }

        if (pessoaProjeto.getNivelAcesso() < 1 || pessoaProjeto.getNivelAcesso() > 3) {
            throw new RuntimeException("nivel de acesso deve ser 1, 2 ou 3");
        }
        validarPremiumParaNivel3(pessoaProjeto);
        return repository.save(pessoaProjeto);
    }

    public PessoaProjeto adicionarPessoaAoProjeto(Long idPessoaLogada, PessoaProjeto pessoaProjeto) {

        Long idProjeto = pessoaProjeto.getProjeto().getIdProjeto();

        if (!podeEditar(idPessoaLogada, idProjeto)) {
            throw new RuntimeException("Somente nível 2 ou 3 pode adicionar pessoas");
        }

        if (pessoaProjeto.getNivelAcesso() > 2) {
            throw new RuntimeException("Só é permitido adicionar nível 1 ou 2");
        }

        return salvar(pessoaProjeto);
    }

    public PessoaProjeto buscarPessoaProjetoid(Long id) {
        return repository.findById(id).orElse(null);
    }

    public void atualizarPessoaProjeto(Long id, PessoaProjeto pessoaProjetoAtualizada) {
        PessoaProjeto pessoaProjeto = repository.findById(id).orElse(null);

        if (pessoaProjeto != null) {
            pessoaProjeto.setNivelAcesso(pessoaProjetoAtualizada.getNivelAcesso());
            repository.save(pessoaProjeto);
        }
    }

    public void deletarPessoaProjeto(Long id) {
        repository.deleteById(id);
    }

    public PessoaProjeto buscarPermissao(Long idPessoa, Long idProjeto) {
        return repository.findByPessoa_IdPessoaAndProjeto_IdProjeto(idPessoa, idProjeto);
    }

    public boolean fazParteDoProjeto(Long idPessoa, Long idProjeto) {
        return buscarPermissao(idPessoa, idProjeto) != null;
    }

    public boolean podeMarcarFeito(Long idPessoa, Long idProjeto) {
        PessoaProjeto permissao = buscarPermissao(idPessoa, idProjeto);
        return permissao != null && permissao.getNivelAcesso() >= 1;
    }

    public boolean podeEditar(Long idPessoa, Long idProjeto) {
        PessoaProjeto permissao = buscarPermissao(idPessoa, idProjeto);
        return permissao != null && permissao.getNivelAcesso() >= 2;
    }

    public boolean ehAdmin(Long idPessoa, Long idProjeto) {
        PessoaProjeto permissao = buscarPermissao(idPessoa, idProjeto);
        return permissao != null && permissao.getNivelAcesso() == 3;
    }
    
    public void transferirAdmin(
        Long idAdminAtual,
        Long idNovoAdmin,
        Long idProjeto) {

    PessoaProjeto adminAtual = buscarPermissao(idAdminAtual, idProjeto);
    PessoaProjeto novoAdmin = buscarPermissao(idNovoAdmin, idProjeto);
    
    if (adminAtual == null || adminAtual.getNivelAcesso() != 3) {
    throw new RuntimeException("Somente nível 3 pode transferir administração");
    }
    
    if (novoAdmin == null) {
    throw new RuntimeException("A pessoa precisa fazer parte do projeto");
    }
    if (idAdminAtual.equals(idNovoAdmin)) {
    throw new RuntimeException("Não é possível transferir administração para si mesmo");
    }

    if (!novoAdmin.getPessoa().isPremium()) {
    long qtdAdmin = repository.countByPessoa_IdPessoaAndNivelAcesso(idNovoAdmin, 3);

        if (qtdAdmin >= 1) {
        throw new RuntimeException("Usuário gratuito só pode ser dono de 1 projeto");
        }
    }

    adminAtual.setNivelAcesso(2);
    novoAdmin.setNivelAcesso(3);

    repository.save(adminAtual);
    repository.save(novoAdmin);
}
public List<PessoaProjeto> listarProjetosDaPessoa(Long idPessoa) {
    return repository.findByPessoa_IdPessoa(idPessoa);
}

public List<PessoaProjeto> listarPessoasDoProjeto(Long idProjeto) {
    return repository.findByProjeto_IdProjeto(idProjeto);
}
public void alterarNivelPessoa(
        Long idPessoaLogada,
        Long idPessoaAlvo,
        Long idProjeto,
        int novoNivel) {

    PessoaProjeto pessoaLogada = buscarPermissao(idPessoaLogada, idProjeto);
    PessoaProjeto pessoaAlvo = buscarPermissao(idPessoaAlvo, idProjeto);

    if (pessoaLogada == null || pessoaLogada.getNivelAcesso() < 2) {
        throw new RuntimeException("Somente nível 2 ou 3 pode alterar níveis");
    }

    if (pessoaAlvo == null) {
        throw new RuntimeException("Pessoa alvo não faz parte do projeto");
    }

    if (novoNivel < 1 || novoNivel > 2) {
        throw new RuntimeException("Só é permitido alterar para nível 1 ou 2");
    }

    if (pessoaAlvo.getNivelAcesso() == 3) {
        throw new RuntimeException("Não é possível alterar nível de um administrador");
    }

    pessoaAlvo.setNivelAcesso(novoNivel);
    repository.save(pessoaAlvo);
}
private void validarPremiumParaNivel3(PessoaProjeto pessoaProjeto) {

    if (pessoaProjeto.getNivelAcesso() == 3) {

        Long idPessoa = pessoaProjeto.getPessoa().getIdPessoa();

        Pessoa pessoaCompleta = pessoaRepository.findById(idPessoa)
                .orElseThrow(() ->
                        new RuntimeException("Pessoa não encontrada"));

        long qtdAdmin = repository.countByPessoa_IdPessoaAndNivelAcesso(
                idPessoa,
                3);

        if (!pessoaCompleta.isPremium() && qtdAdmin >= 1) {
            throw new RuntimeException(
                    "Usuário gratuito só pode ser dono de 1 projeto");
        }
    }
}
public PessoaProjeto adicionarPessoaPorEmail(
        Long idPessoaLogada,
        AdicionarPessoaProjetoRequest request) {

    if (!podeEditar(idPessoaLogada, request.getIdProjeto())) {
        throw new RuntimeException("Somente nível 2 ou 3 pode adicionar pessoas");
    }

    if (request.getNivelAcesso() < 1 || request.getNivelAcesso() > 2) {
        throw new RuntimeException("Só é permitido adicionar nível 1 ou 2");
    }

    var pessoa = pessoaRepository.findByEmail(request.getEmail());

    if (pessoa == null) {
        throw new RuntimeException("Pessoa com esse email não encontrada");
    }

    var projeto = projetoRepository.findById(request.getIdProjeto()).orElse(null);

    if (projeto == null) {
        throw new RuntimeException("Projeto não encontrado");
    }

    if (buscarPermissao(pessoa.getIdPessoa(), request.getIdProjeto()) != null) {
        throw new RuntimeException("Pessoa já faz parte desse projeto");
    }

    PessoaProjeto pessoaProjeto = new PessoaProjeto();
    pessoaProjeto.setPessoa(pessoa);
    pessoaProjeto.setProjeto(projeto);
    pessoaProjeto.setNivelAcesso(request.getNivelAcesso());

    return salvar(pessoaProjeto);
}
}