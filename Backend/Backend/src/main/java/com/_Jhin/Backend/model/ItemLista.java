package com._Jhin.Backend.model;

import jakarta.persistence.*;

@Entity
public class ItemLista {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    
    @Column(name="id_item")
    private Long id_Item;

    @Column(name="nome_item")
    private String nomeItem;

    @Column(name="quantidade")
    private Integer quantidade = 1;

    @Column(name="concluido")
    private boolean concluido = false;

    @Column(name="tarefa")
    private boolean isTarefa;

    @ManyToOne
    @JoinColumn(name = "id_Lista")
    private Lista lista;

    public Long getId_Item() {
        return id_Item;
    }

    public void setId_Item(Long id_Item) {
        this.id_Item = id_Item;
    }

    public String getNomeItem() {
        return nomeItem;
    }

    public void setNomeItem(String nome) {
        this.nomeItem = nome;
    }


    public Integer getQuantidade() {
        return quantidade;
    }

    public void setQuantidade(Integer quantidade) {
        this.quantidade = quantidade;
    }

    public boolean isConcluido() {
        return concluido;
    }

    public void setConcluido(boolean concluido) {
        this.concluido = concluido;
    }

    public boolean getIsTarefa() {
        return isTarefa;
    }

    public void setIsTarefa(boolean isTarefa) {
        this.isTarefa = isTarefa;
    }

    public Lista getLista() {
        return lista;
    }

    public void setLista(Lista lista) {
        this.lista = lista;
    }
}