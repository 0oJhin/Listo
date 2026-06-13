package com._Jhin.Backend.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com._Jhin.Backend.Service.PessoaProjetoService;
import com._Jhin.Backend.model.PessoaProjeto;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;



@RestController
@RequestMapping("/PessoaProjeto")
public class PessoaProjetoController {
    
    private final PessoaProjetoService service;
    
    public PessoaProjetoController(PessoaProjetoService service){
        this.service=service;
    }

    @GetMapping("/{id_PessoaProjeto}")
    public PessoaProjeto getPessoaProjeto(@PathVariable Long id_PessoaProjeto) {
        return service.buscarPessoaProjetoid(id_PessoaProjeto);
    }

    @PostMapping
    public PessoaProjeto salvar(@RequestBody PessoaProjeto pessoa) {
    return service.salvar(pessoa);
    }

    @PutMapping("/{id_PessoaProjeto}")
    public void atualizarPessoaProjeto(
        @PathVariable Long id_PessoaProjeto,
        @RequestBody PessoaProjeto pessoaProjetoAtualizado) {
        service.atualizarPessoaProjeto(id_PessoaProjeto, pessoaProjetoAtualizado);
    }

    @DeleteMapping("/{id_PessoaProjeto}")
    public void deletarPessoaProjeto(@PathVariable Long id_PessoaProjeto) {
    service.deletarPessoaProjeto(id_PessoaProjeto);
    }
    
}