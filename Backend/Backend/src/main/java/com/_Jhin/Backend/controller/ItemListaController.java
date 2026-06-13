package com._Jhin.Backend.controller;

import org.springframework.web.bind.annotation.*;

import com._Jhin.Backend.Service.ItemListaService;
import com._Jhin.Backend.model.ItemLista;

@RestController
@RequestMapping("/itemLista")
public class ItemListaController {

    private final ItemListaService service;

    public ItemListaController(ItemListaService service) {
        this.service = service;
    }

    @GetMapping("/{id_ItemLista}")
    public ItemLista getItemLista(@PathVariable Long id_ItemLista) {
        return service.buscarIdItemLista(id_ItemLista);
    }

    @PostMapping
    public ItemLista salvar(@RequestBody ItemLista item) {
        return service.salvar(item);
    }

    @PutMapping("/{id_Item}")
    public void atualizarItemLista(
            @PathVariable Long id_Item,
            @RequestBody ItemLista itemAtualizado) {

        service.atualizarItemLista(id_Item, itemAtualizado);
    }

    @DeleteMapping("/{id_Item}")
    public void deletarItemLista(@PathVariable Long id_Item) {
        service.deletarItemLista(id_Item);
    }
}