import 'package:flutter/material.dart';

import '../../../components/empty_state.dart';
import '../../../components/entity_card.dart';
import '../../../components/listo_input_field.dart';
import '../../../components/page_scroll.dart';
import '../../../components/primary_button.dart';
import '../../../components/section_card.dart';
import '../../../components/section_title.dart';
import '../../../components/small_button.dart';
import '../../../models/projeto_model.dart';

class ProjetosTab extends StatelessWidget {
  final TextEditingController nomeProjetoController;
  final TextEditingController buscarProjetoController;
  final List<ProjetoModel> projetos;
  final bool carregando;
  final VoidCallback onCriarProjeto;
  final VoidCallback onBuscarProjeto;
  final ValueChanged<ProjetoModel> onEditarProjeto;
  final ValueChanged<ProjetoModel> onDeletarProjeto;

  const ProjetosTab({
    super.key,
    required this.nomeProjetoController,
    required this.buscarProjetoController,
    required this.projetos,
    required this.carregando,
    required this.onCriarProjeto,
    required this.onBuscarProjeto,
    required this.onEditarProjeto,
    required this.onDeletarProjeto,
  });

  @override
  Widget build(BuildContext context) {
    return PageScroll(
      children: [
        SectionCard(
          title: 'Criar projeto',
          subtitle: 'Projeto é a pasta principal onde ficam as listas.',
          icon: Icons.create_new_folder_rounded,
          child: Column(
            children: [
              ListoInputField(
                controller: nomeProjetoController,
                label: 'Nome do projeto',
                hint: 'Ex: Projeto da faculdade',
                icon: Icons.folder_outlined,
              ),
              const SizedBox(height: 14),
              PrimaryButton(
                text: 'Criar projeto',
                icon: Icons.add_rounded,
                loading: carregando,
                onPressed: onCriarProjeto,
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'Buscar projeto por ID',
          subtitle: 'Use para carregar um projeto específico pelo ID.',
          icon: Icons.search_rounded,
          child: Row(
            children: [
              Expanded(
                child: ListoInputField(
                  controller: buscarProjetoController,
                  label: 'ID do projeto',
                  hint: 'Ex: 1',
                  icon: Icons.tag_rounded,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              SmallButton(
                label: 'Buscar',
                icon: Icons.search_rounded,
                onPressed: onBuscarProjeto,
              ),
            ],
          ),
        ),
        SectionTitle(title: 'Projetos carregados', count: projetos.length),
        if (projetos.isEmpty)
          const EmptyState(
            text: 'Crie ou busque um projeto para ele aparecer aqui.',
          )
        else
          ...projetos.map(
            (projeto) => EntityCard(
              title: projeto.nomeProjeto,
              subtitle: 'ID: ${projeto.idProjeto ?? '-'}',
              icon: Icons.folder_rounded,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Editar',
                    onPressed: () => onEditarProjeto(projeto),
                    icon: const Icon(Icons.edit_rounded),
                  ),
                  IconButton(
                    tooltip: 'Deletar',
                    onPressed: () => onDeletarProjeto(projeto),
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
