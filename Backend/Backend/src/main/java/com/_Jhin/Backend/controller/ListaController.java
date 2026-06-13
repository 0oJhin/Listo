package com._Jhin.Backend.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com._Jhin.Backend.model.Lista;
import com._Jhin.Backend.Service.ListaService;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;



@RestController
@RequestMapping("/Lista")
public class ListaController {

    private final ListaService service;
   
    public ListaController(ListaService service){
        this.service = service;
    }
    
    @GetMapping("/{id_Lista}")
    public Lista getLista(@PathVariable Long id_Lista) {
    return service.buscarListaId(id_Lista);
    }

    @PostMapping
    public Lista salvar(@RequestBody Lista lista) {
        return service.salvar(lista);
    }

    @PutMapping("/{id_Lista}")
    public void atualizarListaController(
        @PathVariable Long id_Lista,
        @RequestBody Lista listaAtualizada) { 
    service.atualizarLista(id_Lista, listaAtualizada);
    }

    @DeleteMapping("/{id_Lista}")
    public void deletarListaController(@PathVariable Long id_Lista){
        service.deletarLista(id_Lista);
    }
    
}
