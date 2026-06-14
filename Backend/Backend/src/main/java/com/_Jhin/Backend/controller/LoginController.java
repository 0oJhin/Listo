package com._Jhin.Backend.controller;

import org.springframework.web.bind.annotation.*;

import com._Jhin.Backend.Service.PessoaService;
import com._Jhin.Backend.model.LoginRequest;
import com._Jhin.Backend.model.Pessoa;

@RestController
@RequestMapping("/login")
public class LoginController {

    private final PessoaService service;

    public LoginController(PessoaService service) {
        this.service = service;
    }

    @PostMapping
    public Pessoa login(@RequestBody LoginRequest request) {

        return service.login(
                request.getEmail(),
                request.getSenha()
        );
    }
}