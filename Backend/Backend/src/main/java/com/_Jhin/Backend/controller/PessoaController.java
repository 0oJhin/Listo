package com._Jhin.Backend.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com._Jhin.Backend.model.Pessoa;
import com._Jhin.Backend.Service.PessoaService;

import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;



@RestController
@RequestMapping("/Pessoa")
public class PessoaController {
    
    private final PessoaService service;
    public PessoaController(PessoaService service){
        this.service =  service;
    }

    @GetMapping("/{id_Pessoa}")
    public Pessoa getPessoa(@PathVariable Long id_Pessoa) {
    return service.encontrarPessoa(id_Pessoa);
    }

    @PostMapping
    public Pessoa salvar(@RequestBody Pessoa pessoa) {
    return service.salvar(pessoa);
    }

    @PutMapping("/{id_Pessoa}")
    public void atualizarPessoa(     @PathVariable Long id_Pessoa, @RequestBody Pessoa pessoaAtualizada) {
        service.atualizaPessoa(id_Pessoa, pessoaAtualizada);
    }
    
    @DeleteMapping("/{id_Pessoa}")
    public void deletarPessoa(@PathVariable long id_Pessoa){
        service.deletarPessoa(id_Pessoa);
    }
    @PutMapping("/{idPessoa}/logado/{idPessoaLogada}")
public void atualizarPessoaComPermissao(
        @PathVariable("idPessoa") Long idPessoa,
        @PathVariable("idPessoaLogada") Long idPessoaLogada,
        @RequestBody Pessoa pessoaAtualizada) {

    service.atualizarPessoaComPermissao(
            idPessoaLogada,
            idPessoa,
            pessoaAtualizada);
}
@GetMapping("/email/{email}")
public Pessoa buscarPorEmail(
        @PathVariable String email) {

    return service.buscarPorEmail(email);
}
    @PutMapping("/premium/{idPessoaLogada}/{idPessoa}")
public void tornarPremium(
        @PathVariable Long idPessoaLogada,
        @PathVariable Long idPessoa) {

    service.tornarPremium(idPessoaLogada, idPessoa);
}
}
