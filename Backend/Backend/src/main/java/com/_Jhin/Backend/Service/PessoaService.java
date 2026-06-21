package com._Jhin.Backend.Service;

import org.springframework.stereotype.Service;

import com._Jhin.Backend.model.Pessoa;
import com._Jhin.Backend.repository.PessoaRepository;


@Service
public class PessoaService {
    
    private final PessoaRepository repository;
    public PessoaService(PessoaRepository repository){
        this.repository=repository;

    }
    public Pessoa salvar(Pessoa pessoa){
        if(pessoa.getNomePessoa()==null){
            throw new RuntimeException("Nome obrigatorio");
        }
        if(pessoa.getEmail()==null){
            throw new RuntimeException("Email obrigatorio");
        }
        if(pessoa.getSenha()==null){
            throw new RuntimeException("Senha obrigatoria");
        }
        return repository.save(pessoa);
    }
    
    public Pessoa encontrarPessoa(Long id){
        return repository.findById(id).orElse(null);
    }

    public void  atualizaPessoa(Long id, Pessoa pessoaAtualizada){
        
        Pessoa pessoa = repository.findById(id).orElse(null);

        if(pessoa!= null){
            pessoa.setNomePessoa(pessoaAtualizada.getNomePessoa());
            pessoa.setSenha(pessoaAtualizada.getSenha());
            repository.save(pessoa);
        }
    }
    public void deletarPessoa(long id){
        repository.deleteById(id);
    }
    public Pessoa login(String email, String senha) {

    Pessoa pessoa = repository.findByEmail(email);

    if (pessoa == null) {
        throw new RuntimeException("Email não encontrado");
    }

    if (!pessoa.getSenha().equals(senha)) {
        throw new RuntimeException("Senha incorreta");
    }

    return pessoa;
}
public void atualizarPessoaComPermissao(
        Long idPessoaLogada,
        Long idPessoaAlvo,
        Pessoa pessoaAtualizada) {

    if (!idPessoaLogada.equals(idPessoaAlvo)) {
        throw new RuntimeException("Você só pode alterar sua própria conta");
    }

    atualizaPessoa(idPessoaAlvo, pessoaAtualizada);
}
public Pessoa buscarPorEmail(String email) {
    return repository.findByEmail(email);
}

public void tornarPremium(
        Long idPessoaLogada,
        Long idPessoa) {

    if (!idPessoaLogada.equals(idPessoa)) {
        throw new RuntimeException(
                "Você só pode alterar sua própria assinatura");
    }

    Pessoa pessoa = repository.findById(idPessoa)
            .orElseThrow(() ->
                    new RuntimeException("Pessoa não encontrada"));

    pessoa.setPremium(true);

    repository.save(pessoa);
}
public void cancelarPremium(
        Long idPessoaLogada,
        Long idPessoa) {

    if (!idPessoaLogada.equals(idPessoa)) {
        throw new RuntimeException(
                "Você só pode alterar sua própria assinatura");
    }

    Pessoa pessoa = repository.findById(idPessoa)
            .orElseThrow(() ->
                    new RuntimeException("Pessoa não encontrada"));

    pessoa.setPremium(false);

    repository.save(pessoa);
}
}
