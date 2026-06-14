package com._Jhin.Backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com._Jhin.Backend.model.ItemLista;

public interface ItemListaRepository extends JpaRepository <ItemLista, Long> {
    // ItemListaRepository
void deleteByLista_IdLista(Long idLista);
}