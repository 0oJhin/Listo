package com._Jhin.Backend.repository;

import org.springframework.data.jpa.repository.JpaRepository;

import com._Jhin.Backend.model.PessoaProjeto;
import java.util.List;
public interface PessoaProjetoRepository extends JpaRepository <PessoaProjeto, Long> {
    PessoaProjeto findByPessoa_IdPessoaAndProjeto_IdProjeto(Long idPessoa, Long idProjeto);
    void deleteByProjeto_IdProjeto(Long idProjeto);

    List<PessoaProjeto> findByPessoa_IdPessoa(Long idPessoa);
}
