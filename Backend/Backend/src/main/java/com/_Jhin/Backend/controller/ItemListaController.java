package com._Jhin.Backend.controller;

import org.springframework.web.bind.annotation.*;

import com._Jhin.Backend.Service.ItemListaService;
import com._Jhin.Backend.model.ItemLista;
import java.util.List;
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
    @PostMapping("/pessoa/{idPessoa}")
public ItemLista salvarComPermissao(
        @PathVariable("idPessoa") Long idPessoa,
        @RequestBody ItemLista item) {

    return service.salvarComPermissao(idPessoa, item);
}
@PutMapping("/{idItem}/pessoa/{idPessoa}")
public void atualizarItemListaComPermissao(
        @PathVariable("idItem") Long idItem,
        @PathVariable("idPessoa") Long idPessoa,
        @RequestBody ItemLista itemAtualizado) {

    service.atualizarItemListaComPermissao(idPessoa, idItem, itemAtualizado);
}
@DeleteMapping("/{idItem}/pessoa/{idPessoa}")
public void deletarItemListaComPermissao(
        @PathVariable("idItem") Long idItem,
        @PathVariable("idPessoa") Long idPessoa) {

    service.deletarItemListaComPermissao(idPessoa, idItem);
}
@PutMapping("/{idItem}/concluido/{idPessoa}")
public void alterarConcluido(
        @PathVariable("idItem") Long idItem,
        @PathVariable("idPessoa") Long idPessoa,
        @RequestBody ItemLista itemAtualizado) {

    service.alterarConcluidoComPermissao(
            idPessoa,
            idItem,
            itemAtualizado.isConcluido());
}
@GetMapping
public List<ItemLista> listarTodos() {
    return service.listarTodos();
}
@GetMapping("/lista/{idLista}")
public List<ItemLista> listarPorLista(
        @PathVariable Long idLista) {

    return service.listarPorLista(idLista);
}

}