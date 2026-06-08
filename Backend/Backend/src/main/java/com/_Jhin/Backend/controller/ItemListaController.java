package com._Jhin.Backend.controller;

import org.springframework.web.bind.annotation.*;

import com._Jhin.Backend.model.ItemLista;
import com._Jhin.Backend.repository.ItemListaRepository;


@RestController
@RequestMapping("/itemLista")
public class ItemListaController {

    private final ItemListaRepository r1;

    public ItemListaController(ItemListaRepository repository) {
        this.r1 = repository;
    }

    @GetMapping("/{id_ItemLista}")
    public ItemLista getItemLista(@PathVariable Long id_ItemLista){
            return r1.findById(id_ItemLista).orElse(null);
    }
    

    @PostMapping
    public ItemLista salvar(@RequestBody ItemLista item) {
        return r1.save(item);
    }
    @PutMapping("/{id_Item}")
    public void atualizarItemLista(
        @PathVariable Long id_Item,
        @RequestBody ItemLista itemAtualizado) {

    ItemLista item = r1.findById(id_Item).orElse(null);

    if (item != null) {

        item.setNomeItem(
                itemAtualizado.getNomeItem()
        );

        item.setConcluido(
                itemAtualizado.isConcluido()
        );

        if (!item.getIsTarefa()) {
            item.setQuantidade(
                    itemAtualizado.getQuantidade()
            );
        }

        r1.save(item);
    }
    }
    @DeleteMapping("/{id_Item}")
    public void deletarItemLista(@PathVariable long id_Item){
        r1.deleteById(id_Item);
    }
}