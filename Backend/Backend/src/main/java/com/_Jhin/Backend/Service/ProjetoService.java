package com._Jhin.Backend.Service;

import com._Jhin.Backend.model.Lista;
import com._Jhin.Backend.model.Pessoa;
import com._Jhin.Backend.model.PessoaProjeto;
import com._Jhin.Backend.model.Projeto;
import com._Jhin.Backend.repository.ProjetoRepository;
import org.springframework.stereotype.Service;
import java.util.List;

import com._Jhin.Backend.repository.ListaRepository;
import com._Jhin.Backend.repository.ItemListaRepository;
import com._Jhin.Backend.repository.PessoaProjetoRepository;
import com._Jhin.Backend.repository.PessoaRepository;

import jakarta.transaction.Transactional;
@Service
public class ProjetoService {
private final PessoaRepository pessoaRepository;
private final ProjetoRepository repository;
private final PessoaProjetoService pessoaProjetoService;
private final ListaRepository listaRepository;
private final ItemListaRepository itemListaRepository;
private final PessoaProjetoRepository pessoaProjetoRepository;

public ProjetoService(
        PessoaRepository pessoaRepository,
        ProjetoRepository repository,
        PessoaProjetoService pessoaProjetoService,
        ListaRepository listaRepository,
        ItemListaRepository itemListaRepository,
        PessoaProjetoRepository pessoaProjetoRepository) {
    this.pessoaRepository = pessoaRepository;
    this.repository = repository;
    this.pessoaProjetoService = pessoaProjetoService;
    this.listaRepository = listaRepository;
    this.itemListaRepository = itemListaRepository;
    this.pessoaProjetoRepository = pessoaProjetoRepository;
}
    public Projeto salvar(Projeto projeto){
        
        if(projeto.getNomeProjeto()==null){
            throw new RuntimeException("Nome do Projeto obrigatorio");
        }
        
        return repository.save(projeto);
    }

    public void atualizarProjeto(Long id, Projeto projetoAtualizado){
        Projeto projeto = repository.findById(id).orElse(null);
        if(projeto!=null){
            projeto.setNomeProjeto(projetoAtualizado.getNomeProjeto());
            repository.save(projeto);
        }
    }

    public Projeto pesquisarProjetoId(Long id){
        return repository.findById(id).orElse(null);
    }

    public void deletarProjeto(Long id){
        repository.deleteById(id);
    }
    
   @Transactional
    public void deletarProjetoComPermissao(Long idPessoa, Long idProjeto) {

    if (!pessoaProjetoService.ehAdmin(idPessoa, idProjeto)) {
        throw new RuntimeException("Somente nível 3 pode deletar projetos");
    }

    List<Lista> listas = listaRepository.findByProjeto_IdProjeto(idProjeto);

    for (Lista lista : listas) {
        itemListaRepository.deleteByLista_IdLista(lista.getIdLista());
    }

    listaRepository.deleteByProjeto_IdProjeto(idProjeto);
    pessoaProjetoRepository.deleteByProjeto_IdProjeto(idProjeto);
    repository.deleteById(idProjeto);
}
public List<Projeto> listarTodos() {
    return repository.findAll();
}
public Projeto salvarComCriador(Long idPessoa, Projeto projeto) {

    Projeto projetoSalvo = salvar(projeto);

    Pessoa pessoa = pessoaRepository.findById(idPessoa)
            .orElseThrow(() ->
                    new RuntimeException("Pessoa não encontrada"));

    PessoaProjeto pessoaProjeto = new PessoaProjeto();

    pessoaProjeto.setPessoa(pessoa);
    pessoaProjeto.setProjeto(projetoSalvo);
    pessoaProjeto.setNivelAcesso(3);

    pessoaProjetoService.salvar(pessoaProjeto);

    return projetoSalvo;
}

}
