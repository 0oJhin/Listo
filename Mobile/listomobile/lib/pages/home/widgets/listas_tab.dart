import 'package:flutter/material.dart';

import '../../../components/empty_state.dart';
import '../../../components/entity_card.dart';
import '../../../components/listo_input_field.dart';
import '../../../components/page_scroll.dart';
import '../../../components/primary_button.dart';
import '../../../components/section_card.dart';
import '../../../components/section_title.dart';
import '../../../components/small_button.dart';
import '../../../core/app_colors.dart';
import '../../../models/lista_model.dart';

typedef ListaFeitaCallback = void Function(ListaModel lista, bool feito);

class ListasTab extends StatelessWidget {
  final TextEditingController nomeListaController;
  final TextEditingController idProjetoDaListaController;
  final TextEditingController buscarListaController;
  final List<ListaModel> listas;
  final bool carregando;
  final bool listaFeitaAoCriar;
  final VoidCallback onCriarLista;
  final VoidCallback onBuscarLista;
  final ValueChanged<bool> onListaFeitaAoCriarChanged;
  final ValueChanged<ListaModel> onEditarLista;
  final ValueChanged<ListaModel> onDeletarLista;
  final ListaFeitaCallback onAlternarListaFeita;

  const ListasTab({
    super.key,
    required this.nomeListaController,
    required this.idProjetoDaListaController,
    required this.buscarListaController,
    required this.listas,
    required this.carregando,
    required this.listaFeitaAoCriar,
    required this.onCriarLista,
    required this.onBuscarLista,
    required this.onListaFeitaAoCriarChanged,
    required this.onEditarLista,
    required this.onDeletarLista,
    required this.onAlternarListaFeita,
  });

  @override
  Widget build(BuildContext context) {
    return PageScroll(
      children: [
        SectionCard(
          title: 'Criar lista',
          subtitle: 'Informe o ID do projeto para vincular a lista.',
          icon: Icons.playlist_add_rounded,
          child: Column(
            children: [
              ListoInputField(
                controller: nomeListaController,
                label: 'Nome da lista',
                hint: 'Ex: Compras do mês',
                icon: Icons.list_alt_outlined,
              ),
              const SizedBox(height: 12),
              ListoInputField(
                controller: idProjetoDaListaController,
                label: 'ID do projeto',
                hint: 'Ex: 1',
                icon: Icons.folder_copy_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 6),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Criar como lista concluída'),
                value: listaFeitaAoCriar,
                activeColor: AppColors.secondary,
                onChanged: onListaFeitaAoCriarChanged,
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                text: 'Criar lista',
                icon: Icons.add_rounded,
                loading: carregando,
                onPressed: onCriarLista,
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'Buscar lista por ID',
          subtitle: 'Use para carregar uma lista já salva no banco.',
          icon: Icons.search_rounded,
          child: Row(
            children: [
              Expanded(
                child: ListoInputField(
                  controller: buscarListaController,
                  label: 'ID da lista',
                  hint: 'Ex: 1',
                  icon: Icons.tag_rounded,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              SmallButton(
                label: 'Buscar',
                icon: Icons.search_rounded,
                onPressed: onBuscarLista,
              ),
            ],
          ),
        ),
        SectionTitle(title: 'Listas carregadas', count: listas.length),
        if (listas.isEmpty)
          const EmptyState(
            text: 'Crie ou busque uma lista para ela aparecer aqui.',
          )
        else
          ...listas.map(
            (lista) => EntityCard(
              title: lista.nomeLista,
              subtitle:
                  'ID: ${lista.idLista ?? '-'} • Projeto: ${lista.idProjeto == 0 ? '-' : lista.idProjeto}',
              icon: lista.feito ? Icons.task_alt_rounded : Icons.list_alt_rounded,
              leadingColor: lista.feito ? AppColors.secondary : AppColors.primary,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: lista.feito,
                    activeColor: AppColors.secondary,
                    onChanged: (value) => onAlternarListaFeita(lista, value ?? false),
                  ),
                  IconButton(
                    tooltip: 'Editar',
                    onPressed: () => onEditarLista(lista),
                    icon: const Icon(Icons.edit_rounded),
                  ),
                  IconButton(
                    tooltip: 'Deletar',
                    onPressed: () => onDeletarLista(lista),
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
