package com._Jhin.Backend.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com._Jhin.Backend.model.PessoaProjeto;
import com._Jhin.Backend.repository.PessoaProjetoRepository;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;



@RestController
@RequestMapping("/PessoaProjeto")
public class PessoaProjetoController {
    
    private final PessoaProjetoRepository r1;
    
    public PessoaProjetoController(PessoaProjetoRepository repository){
        this.r1 =  repository;
    }
    @GetMapping("/{id_PessoaProjeto}")
    public PessoaProjeto getPessoaProjeto(@PathVariable Long id_PessoaProjeto) {
        return r1.findById(id_PessoaProjeto).orElse(null);
    }
    @PostMapping
    public PessoaProjeto salvar(@RequestBody PessoaProjeto pessoa) {
    return r1.save(pessoa);
    }
}