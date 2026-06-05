package com._Jhin.Backend.model;

import jakarta.persistence.*;

import java.util.List;

@Entity
public class Projeto {


        @Id
        @GeneratedValue(strategy = GenerationType.IDENTITY)
        @Column(name = "id_projeto")
        private Long id_Projeto;

        @Column(name = "nome_projeto")
        private String nomeProjeto;     

        @OneToMany(mappedBy = "projeto")
        private List<Lista> listas;

        public long getIdProjeto(){
                return id_Projeto;
        }
        public void setIdProjeto(long idProjeto){
                this.id_Projeto=idProjeto;
        }
        public String getNomeProjeto(){
                return nomeProjeto;
        }
        public void setNomeProjeto(String nomeProjeto){
                this.nomeProjeto=nomeProjeto;
        }

}
