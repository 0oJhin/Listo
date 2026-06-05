package com._Jhin.Backend.model;

import jakarta.persistence.*;
import java.util.List;


@Entity
public class Lista {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    
    @Column(name="id_lista")
    private long id_Lista;

    @Column(name="nome_lista")
    private String nomeLista;

    @Column(name="feito")
    private boolean feito;

    @ManyToOne
    @JoinColumn(name = "id_Projeto")
    private Projeto projeto;

    @OneToMany(mappedBy = "lista")
    private List<ItemLista> itens;
    
    public long getIdLista(){
        return id_Lista;
    }        
    public void setIdLista(Long id_Lista){
        this.id_Lista= id_Lista;
    }
    public String getNomeLista(){
        return nomeLista;
    }
    public void setNome(String nome){
        this.nomeLista=nome;
    }
    public boolean isFeito() {
        return feito;
    }

    public void setConcluido(boolean feito) {
        this.feito = feito;
    }
        
}
