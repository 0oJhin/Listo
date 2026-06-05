package com._Jhin.Backend.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com._Jhin.Backend.model.Lista;
import com._Jhin.Backend.repository.ListaRepository;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
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
}
