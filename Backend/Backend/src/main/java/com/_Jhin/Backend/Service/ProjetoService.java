package com._Jhin.Backend.Service;

import com._Jhin.Backend.model.Projeto;
import com._Jhin.Backend.repository.ProjetoRepository;
import org.springframework.stereotype.Service;

@Service
public class ProjetoService {
    private final ProjetoRepository repository;
    public ProjetoService(ProjetoRepository repository){
        this.repository=repository;
    }

    public Projeto salvar(Projeto projeto){
        
        if(projeto.getNomeProjeto()==null){
            throw new RuntimeException("Nome do Projeto obrigatorio");
        }
        
        return repository.save(projeto);
    }

    public void atualizarProjeto(Long id, Projeto projetoAtualizado){
        Projeto projeto = repository.findById(id).orElse(null);
        if(projeto!=null){
            projeto.setNomeProjeto(projetoAtualizado.getNomeProjeto());
            repository.save(projeto);
        }
    }

    public Projeto pesquisarProjetoId(Long id){
        return repository.findById(id).orElse(null);
    }

    public void deletarProjeto(Long id){
        repository.deleteById(id);
    }
}
