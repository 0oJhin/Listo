package com._Jhin.Backend.model;


import jakarta.persistence.*;


@Entity
public class Pessoa {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    
    @Column(name="id_Pesssoa")
    private long id_Pesssoa;

    @Column(name="nome_Pessoa")
    private String nomePessoa;
    
    @Column(name="email")
    private String email;
    
    @Column(name="senha")
    private String senha;

    public long getIdPessoa(){
        return id_Pesssoa;
    }
    public void setIdPessoa(long id_Pessoa){
        this.id_Pesssoa=id_Pessoa;
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
