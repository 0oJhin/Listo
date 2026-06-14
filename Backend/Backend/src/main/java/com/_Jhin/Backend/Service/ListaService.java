package com._Jhin.Backend.Service;
import com._Jhin.Backend.model.Lista;
import com._Jhin.Backend.repository.ListaRepository;

import org.springframework.stereotype.Service;

@Service
public class ListaService {
   private final ListaRepository repository;
    private final PessoaProjetoService pessoaProjetoService;

public ListaService(
        ListaRepository repository,
        PessoaProjetoService pessoaProjetoService) {
    this.repository = repository;
    this.pessoaProjetoService = pessoaProjetoService;
}

    public Lista salvar(Lista lista){
        if (lista.getNomeLista() == null || lista.getNomeLista().isBlank()) {
            throw new RuntimeException("Nome da lista é obrigatório");
        }

        if (lista.getProjeto() == null || lista.getProjeto().getIdProjeto() == null) {
            throw new RuntimeException("Lista precisa estar vinculada a um projeto");
        }
    return repository.save(lista);
    }
    
    public Lista buscarListaId(Long id){
        return repository.findById(id).orElse(null);
    }

    public void atualizarLista(Long id,Lista listaAtualizada){
        
        Lista lista = repository.findById(id).orElse(null);
        if(lista != null){
            lista.setNomeLista(listaAtualizada.getNomeLista());
            lista.setFeito(listaAtualizada.isFeito());
            repository.save(lista);
        }
    }
    
    public void deletarLista(long id){
        repository.deleteById(id);
    }


    public Lista salvarComPermissao(Long idPessoa, Lista lista) {

    Long idProjeto = lista.getProjeto().getIdProjeto();

    if (!pessoaProjetoService.podeEditar(idPessoa, idProjeto)) {
        throw new RuntimeException("Somente nível 2 ou 3 pode criar listas");
    }

    return salvar(lista);
}
public void atualizarListaComPermissao(
        Long idPessoa,
        Long idLista,
        Lista listaAtualizada) {

    Lista lista = repository.findById(idLista).orElse(null);

    if (lista == null) {
        throw new RuntimeException("Lista não encontrada");
    }

    Long idProjeto = lista.getProjeto().getIdProjeto();

    if (!pessoaProjetoService.podeEditar(idPessoa, idProjeto)) {
        throw new RuntimeException("Somente nível 2 ou 3 pode alterar listas");
    }

    lista.setNomeLista(listaAtualizada.getNomeLista());
    lista.setFeito(listaAtualizada.isFeito());

    repository.save(lista);
}
public void deletarListaComPermissao(Long idPessoa, Long idLista) {

    Lista lista = repository.findById(idLista).orElse(null);

    if (lista == null) {
        throw new RuntimeException("Lista não encontrada");
    }

    Long idProjeto = lista.getProjeto().getIdProjeto();

    if (!pessoaProjetoService.podeEditar(idPessoa, idProjeto)) {
        throw new RuntimeException("Somente nível 2 ou 3 pode deletar listas");
    }

    repository.deleteById(idLista);
}
}
