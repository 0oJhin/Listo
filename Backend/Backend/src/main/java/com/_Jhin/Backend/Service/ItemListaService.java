package com._Jhin.Backend.Service;

import org.springframework.stereotype.Service;

import com._Jhin.Backend.model.ItemLista;
import com._Jhin.Backend.repository.ItemListaRepository;

@Service
public class ItemListaService {
    private final ItemListaRepository repository;

    public ItemListaService(ItemListaRepository repository){
        this.repository= repository;
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

}
