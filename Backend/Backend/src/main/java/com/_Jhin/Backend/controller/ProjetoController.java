package com._Jhin.Backend.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com._Jhin.Backend.model.Projeto;
import com._Jhin.Backend.repository.ProjetoRepository;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;



@RestController
@RequestMapping("/Projeto")
public class ProjetoController {
    
    private final ProjetoRepository r1;
    
    public ProjetoController(ProjetoRepository repository){
        this.r1 =  repository;
    }
    @GetMapping("/{id_Projeto}")
    public Projeto getProjeto(@PathVariable Long id_Projeto){
    return r1.findById(id_Projeto).orElse(null);
    }
    @PostMapping
    public Projeto salvar(@RequestBody Projeto projeto) {
    return r1.save(projeto);
    }
}