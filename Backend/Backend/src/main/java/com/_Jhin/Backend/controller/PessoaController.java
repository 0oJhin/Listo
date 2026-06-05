package com._Jhin.Backend.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com._Jhin.Backend.model.Pessoa;
import com._Jhin.Backend.repository.PessoaRepository;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;



@RestController
@RequestMapping("/Pessoa")
public class PessoaController {
    
    private final PessoaRepository r1;
    
    public PessoaController(PessoaRepository repository){
        this.r1 =  repository;
    }
    @GetMapping("/{id_Pessoa}")
    public Pessoa getPessoa(@PathVariable Long id_Pessoa) {
    return r1.findById(id_Pessoa).orElse(null);
    }
    @PostMapping
    public Pessoa salvar(@RequestBody Pessoa pessoa) {
    return r1.save(pessoa);
    }
}
