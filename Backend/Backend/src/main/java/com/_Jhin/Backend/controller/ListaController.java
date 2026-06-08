package com._Jhin.Backend.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com._Jhin.Backend.model.Lista;
import com._Jhin.Backend.repository.ListaRepository;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;



@RestController
@RequestMapping("/Lista")
public class ListaController {

    private final ListaRepository r1;
   
    public ListaController(ListaRepository repository){
        this.r1 = repository;
    }
    
    @GetMapping("/{id_Lista}")
    public Lista getLista(@PathVariable Long id_Lista) {
    return r1.findById(id_Lista).orElse(null);
    }

    @PostMapping
    public Lista salvar(@RequestBody Lista lista) {
        return r1.save(lista);
    }
    @PutMapping("/{id_Lista}")
    public void atualizarLista(
        @PathVariable Long id_Lista,
        @RequestBody Lista listaAtualizada) {

    Lista lista = r1.findById(id_Lista).orElse(null);

    if (lista != null) {
        lista.setNomeLista(listaAtualizada.getNomeLista());
        lista.setFeito(listaAtualizada.isFeito());
        r1.save(lista);
    }
    }
    @DeleteMapping("/{id_Lista}")
    public void deletarLista(@PathVariable Long id_Lista){
        r1.deleteById(id_Lista);
    }
    
}
