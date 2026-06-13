package com._Jhin.Backend.Service;
import com._Jhin.Backend.model.Lista;
import com._Jhin.Backend.repository.ListaRepository;

import org.springframework.stereotype.Service;

@Service
public class ListaService {
    private final ListaRepository repository;
    public ListaService(ListaRepository repository){
        this.repository=repository;
    }

    public Lista salvar(Lista lista){
        if (lista.getNomeLista() == null || lista.getNomeLista().isBlank()) {
            throw new RuntimeException("Nome da lista é obrigatório");
        }

        if (lista.getProjeto() == null || lista.getProjeto().getIdProjeto() == null) {
            throw new RuntimeException("Lista precisa estar vinculada a um projeto");
        }
    return repository.save(lista);
    }
    
    public Lista buscarListaId(Long id){
        return repository.findById(id).orElse(null);
    }

    public void atualizarLista(Long id,Lista listaAtualizada){
        
        Lista lista = repository.findById(id).orElse(null);
        if(lista != null){
            lista.setNomeLista(listaAtualizada.getNomeLista());
            lista.setFeito(listaAtualizada.isFeito());
            repository.save(lista);
        }
    }
    
    public void deletarLista(long id){
        repository.deleteById(id);
    }

}
