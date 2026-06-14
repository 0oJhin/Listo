package com._Jhin.Backend.model;


import com.fasterxml.jackson.annotation.JsonProperty;

import jakarta.persistence.*;


@Entity
public class Pessoa {

    @Id
@GeneratedValue(strategy = GenerationType.IDENTITY)
@Column(name = "id_pessoa")
private Long idPessoa;

    @Column(name="nome_Pessoa")
    private String nomePessoa;
    
    @Column(name="email")
    private String email;
    
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    @Column(name="senha")
    private String senha;

    public Long getIdPessoa() {
    return idPessoa;
}

public void setIdPessoa(Long idPessoa) {
    this.idPessoa = idPessoa;
}
    public String getNomePessoa(){
        return nomePessoa;
    }
    public void setNomePessoa(String nome){
        this.nomePessoa = nome; 
    }
    public String getEmail(){
        return email;
    }
    public void setEmail(String email){
        this.email = email; 
    }
    public String getSenha(){
        return senha;
    }
    public void setSenha(String senha){
        this.senha = senha; 
    }
}
