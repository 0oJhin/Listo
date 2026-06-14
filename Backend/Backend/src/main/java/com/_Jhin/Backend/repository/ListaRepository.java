package com._Jhin.Backend.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import com._Jhin.Backend.model.Lista;

public interface ListaRepository extends JpaRepository<Lista, Long> {

    List<Lista> findByProjeto_IdProjeto(Long idProjeto);

    void deleteByProjeto_IdProjeto(Long idProjeto);
}