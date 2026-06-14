package com._Jhin.Backend.Service;

import com._Jhin.Backend.model.PessoaProjeto;
import com._Jhin.Backend.repository.PessoaProjetoRepository;
import org.springframework.stereotype.Service;

@Service
public class PessoaProjetoService {

    private final PessoaProjetoRepository repository;

    public PessoaProjetoService(PessoaProjetoRepository repository) {
        this.repository = repository;
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
}