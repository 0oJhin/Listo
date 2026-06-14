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
public PessoaProjeto getPessoaProjeto(
        @PathVariable("id_PessoaProjeto") Long idPessoaProjeto) {
    return service.buscarPessoaProjetoid(idPessoaProjeto);
}

@PutMapping("/{id_PessoaProjeto}")
public void atualizarPessoaProjeto(
        @PathVariable("id_PessoaProjeto") Long idPessoaProjeto,
        @RequestBody PessoaProjeto pessoaProjetoAtualizado) {
    service.atualizarPessoaProjeto(idPessoaProjeto, pessoaProjetoAtualizado);
}

@DeleteMapping("/{id_PessoaProjeto}")
public void deletarPessoaProjeto(
        @PathVariable("id_PessoaProjeto") Long idPessoaProjeto) {
    service.deletarPessoaProjeto(idPessoaProjeto);
}

    @PostMapping
    public PessoaProjeto salvar(@RequestBody PessoaProjeto pessoa) {
    return service.salvar(pessoa);
    }




@PostMapping("/adicionar/{idPessoaLogada}")
public PessoaProjeto adicionarPessoaAoProjeto(
        @PathVariable("idPessoaLogada") Long idPessoaLogada,
        @RequestBody PessoaProjeto pessoaProjeto) {

    return service.adicionarPessoaAoProjeto(
            idPessoaLogada,
            pessoaProjeto);
}
@PutMapping("/transferir-admin/{idAdminAtual}/{idNovoAdmin}/{idProjeto}")
public void transferirAdmin(
        @PathVariable("idAdminAtual") Long idAdminAtual,
        @PathVariable("idNovoAdmin") Long idNovoAdmin,
        @PathVariable("idProjeto") Long idProjeto) {

    service.transferirAdmin(idAdminAtual, idNovoAdmin, idProjeto);
}
}