package com._Jhin.Backend.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com._Jhin.Backend.Service.ProjetoService;
import com._Jhin.Backend.model.Projeto;
import java.util.List;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.PutMapping;





@RestController
@RequestMapping("/Projeto")
public class ProjetoController {
    
    private final ProjetoService service ;
    
    public ProjetoController(ProjetoService service){
        this.service =  service;
    }

    @GetMapping("/{id_Projeto}")
    public Projeto getProjeto(@PathVariable Long id_Projeto){
    return service.pesquisarProjetoId(id_Projeto);
    }
    
    @PostMapping
    public Projeto salvar(@RequestBody Projeto projeto) {
    return service.salvar(projeto);
    }

    @PutMapping("/{id_Projeto}")
    public void atualizarProjeto(
        @PathVariable Long id_Projeto,
        @RequestBody Projeto projetoAtualizado) {
            service.atualizarProjeto(id_Projeto, projetoAtualizado);
    }
    @DeleteMapping("/{id_Projeto}")
    public void deletarProjeto(@PathVariable Long id_Projeto) {
    service.deletarProjeto(id_Projeto);
    }
    @DeleteMapping("/{idProjeto}/pessoa/{idPessoa}")
public void deletarProjetoComPermissao(
        @PathVariable("idProjeto") Long idProjeto,
        @PathVariable("idPessoa") Long idPessoa) {

    service.deletarProjetoComPermissao(
            idPessoa,
            idProjeto);
}
@GetMapping
public List<Projeto> listarTodos() {
    return service.listarTodos();
}
}