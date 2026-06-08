package com._Jhin.Backend.model;


import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;

@Entity
public class PessoaProjeto {


    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name="id_pessoa_projeto")
    private long id_PessoaProjeto ;

    @Column(name="nivel_acesso")
    private int nivelAcesso;

    @ManyToOne
    @JoinColumn(name = "id_pessoa")
    private Pessoa pessoa;

    @ManyToOne
    @JoinColumn(name = "id_projeto")
    private Projeto projeto;
    
    public long getIdPessoaProjeto(){
        return id_PessoaProjeto;
    }
    public void setIdPessoaProjeto(long idPessoaProjeto){
        this.id_PessoaProjeto=idPessoaProjeto;
    }
    
    public int getNivelAcesso(){
        return nivelAcesso;
    }
    public void setNivelAcesso(int nivelAcesso){
        this.nivelAcesso=nivelAcesso;
    }
    public Pessoa getPessoa() {
    return pessoa;
}

public void setPessoa(Pessoa pessoa) {
    this.pessoa = pessoa;
}

public Projeto getProjeto() {
    return projeto;
}

public void setProjeto(Projeto projeto) {
    this.projeto = projeto;
}

}
