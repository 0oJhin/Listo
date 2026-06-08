package com._Jhin.Backend.model;

import jakarta.persistence.*;
import java.util.List;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;

@JsonPropertyOrder({
    "idLista",
    "nomeLista",
    "feito",
    "projeto",
    "itens"
})

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
    @JoinColumn(name = "id_projeto")
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
    public void setNomeLista(String nome){
        this.nomeLista=nome;
    }
    public boolean isFeito() {
        return feito;
    }

    public void setFeito(boolean feito) {
    this.feito = feito;
    }
     public Projeto getProjeto() {
    return projeto;
    }

    public void setProjeto(Projeto projeto) {
    this.projeto = projeto;
    }
    public List<ItemLista> getItens() {
    return itens;
    }

    public void setItens(List<ItemLista> itens) {
    this.itens = itens;
    }   
}
