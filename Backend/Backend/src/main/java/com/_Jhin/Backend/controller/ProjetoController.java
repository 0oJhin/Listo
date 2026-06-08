package com._Jhin.Backend.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com._Jhin.Backend.model.Projeto;
import com._Jhin.Backend.repository.ProjetoRepository;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.PutMapping;





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

    @PutMapping("/{id_Projeto}")
    public void atualizarProjeto(
        @PathVariable Long id_Projeto,
        @RequestBody Projeto projetoAtualizado) {

    Projeto projeto = r1.findById(id_Projeto).orElse(null);

    if (projeto != null) {
        projeto.setNomeProjeto(projetoAtualizado.getNomeProjeto());
        r1.save(projeto);
    }
    }
    @DeleteMapping("/{id_Projeto}")
    public void deletarProjeto(@PathVariable Long id_Projeto) {
    r1.deleteById(id_Projeto);
    }
    
}