package com._Jhin.Backend.Service;

import org.springframework.stereotype.Service;

import com._Jhin.Backend.model.ItemLista;
import com._Jhin.Backend.repository.ItemListaRepository;
import com._Jhin.Backend.repository.ListaRepository;
import com._Jhin.Backend.model.Lista;

@Service
public class ItemListaService {
private final ItemListaRepository repository;
private final PessoaProjetoService pessoaProjetoService;
private final ListaRepository listaRepository;

public ItemListaService(
        ItemListaRepository repository,
        PessoaProjetoService pessoaProjetoService,
        ListaRepository listaRepository) {
    this.repository = repository;
    this.pessoaProjetoService = pessoaProjetoService;
    this.listaRepository = listaRepository;
}
    

    public ItemLista salvar(ItemLista item){
        if(item.getIsTarefa()){
            item.setQuantidade(1);
        }else{
            if (item.getQuantidade() == null || item.getQuantidade() < 1) {
                throw new RuntimeException("Quantidade deve ser maior ou igual a 1");
            }
        }
        return repository.save(item);
    }

    public ItemLista buscarIdItemLista(Long id){
        return repository.findById(id).orElse(null);
    }
    public void deletarItemLista(long id){
        repository.deleteById(id);
    }
    public void atualizarItemLista(Long id, ItemLista itemAtualizado) {

    ItemLista item = repository.findById(id).orElse(null);

    if (item != null) {

        item.setNomeItem(itemAtualizado.getNomeItem());
        item.setConcluido(itemAtualizado.isConcluido());

        if (item.getIsTarefa()) {
            item.setQuantidade(1);
        } else {
            if (itemAtualizado.getQuantidade() == null || itemAtualizado.getQuantidade() < 1) {
                throw new RuntimeException("Quantidade deve ser maior ou igual a 1");
            }

            item.setQuantidade(itemAtualizado.getQuantidade());
        }

        repository.save(item);
    }
}
public ItemLista salvarComPermissao(Long idPessoa, ItemLista item) {

    Long idLista = item.getLista().getIdLista();

    Lista lista = listaRepository.findById(idLista)
            .orElseThrow(() -> new RuntimeException("Lista não encontrada"));

    Long idProjeto = lista.getProjeto().getIdProjeto();

    if (!pessoaProjetoService.podeEditar(idPessoa, idProjeto)) {
        throw new RuntimeException("Somente nível 2 ou 3 pode criar itens");
    }

    item.setLista(lista);

    return salvar(item);
}
public void atualizarItemListaComPermissao(
        Long idPessoa,
        Long idItem,
        ItemLista itemAtualizado) {

    ItemLista item = repository.findById(idItem).orElse(null);

    if (item == null) {
        throw new RuntimeException("Item não encontrado");
    }

    Long idProjeto = item.getLista().getProjeto().getIdProjeto();

    if (!pessoaProjetoService.podeEditar(idPessoa, idProjeto)) {
        throw new RuntimeException("Somente nível 2 ou 3 pode alterar itens");
    }

    atualizarItemLista(idItem, itemAtualizado);
}
public void deletarItemListaComPermissao(Long idPessoa, Long idItem) {

    ItemLista item = repository.findById(idItem).orElse(null);

    if (item == null) {
        throw new RuntimeException("Item não encontrado");
    }

    Long idProjeto = item.getLista().getProjeto().getIdProjeto();

    if (!pessoaProjetoService.podeEditar(idPessoa, idProjeto)) {
        throw new RuntimeException("Somente nível 2 ou 3 pode deletar itens");
    }

    repository.deleteById(idItem);
}
public void alterarConcluidoComPermissao(
        Long idPessoa,
        Long idItem,
        boolean concluido) {

    ItemLista item = repository.findById(idItem).orElse(null);

    if (item == null) {
        throw new RuntimeException("Item não encontrado");
    }

    Long idProjeto = item.getLista().getProjeto().getIdProjeto();

    if (!pessoaProjetoService.podeMarcarFeito(idPessoa, idProjeto)) {
        throw new RuntimeException("A pessoa não faz parte do projeto");
    }

    item.setConcluido(concluido);
    repository.save(item);
}

}
