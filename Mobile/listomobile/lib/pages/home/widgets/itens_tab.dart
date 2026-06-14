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
import '../../../models/item_lista_model.dart';

typedef ItemConcluidoCallback = void Function(ItemListaModel item, bool concluido);

class ItensTab extends StatelessWidget {
  final TextEditingController nomeItemController;
  final TextEditingController quantidadeItemController;
  final TextEditingController idListaDoItemController;
  final TextEditingController buscarItemController;
  final List<ItemListaModel> itens;
  final bool carregando;
  final bool itemEhTarefa;
  final VoidCallback onCriarItem;
  final VoidCallback onBuscarItem;
  final ValueChanged<bool> onItemEhTarefaChanged;
  final ValueChanged<ItemListaModel> onEditarItem;
  final ValueChanged<ItemListaModel> onDeletarItem;
  final ItemConcluidoCallback onAlternarItemConcluido;

  const ItensTab({
    super.key,
    required this.nomeItemController,
    required this.quantidadeItemController,
    required this.idListaDoItemController,
    required this.buscarItemController,
    required this.itens,
    required this.carregando,
    required this.itemEhTarefa,
    required this.onCriarItem,
    required this.onBuscarItem,
    required this.onItemEhTarefaChanged,
    required this.onEditarItem,
    required this.onDeletarItem,
    required this.onAlternarItemConcluido,
  });

  @override
  Widget build(BuildContext context) {
    return PageScroll(
      children: [
        SectionCard(
          title: 'Criar item',
          subtitle: 'Item pode ser tarefa ou item de quantidade.',
          icon: Icons.add_task_rounded,
          child: Column(
            children: [
              ListoInputField(
                controller: nomeItemController,
                label: 'Nome do item',
                hint: 'Ex: Estudar Sinais',
                icon: Icons.check_box_outlined,
              ),
              const SizedBox(height: 12),
              ListoInputField(
                controller: idListaDoItemController,
                label: 'ID da lista',
                hint: 'Ex: 1',
                icon: Icons.list_alt_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              ListoInputField(
                controller: quantidadeItemController,
                label: 'Quantidade',
                hint: 'Ex: 3',
                icon: Icons.numbers_rounded,
                enabled: !itemEhTarefa,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 6),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Esse item é uma tarefa'),
                subtitle: const Text('Se for tarefa, a quantidade fica 1.'),
                value: itemEhTarefa,
                activeColor: AppColors.secondary,
                onChanged: onItemEhTarefaChanged,
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                text: 'Criar item',
                icon: Icons.add_rounded,
                loading: carregando,
                onPressed: onCriarItem,
              ),
            ],
          ),
        ),
        SectionCard(
          title: 'Buscar item por ID',
          subtitle: 'Use para carregar um item já salvo no banco.',
          icon: Icons.search_rounded,
          child: Row(
            children: [
              Expanded(
                child: ListoInputField(
                  controller: buscarItemController,
                  label: 'ID do item',
                  hint: 'Ex: 1',
                  icon: Icons.tag_rounded,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              SmallButton(
                label: 'Buscar',
                icon: Icons.search_rounded,
                onPressed: onBuscarItem,
              ),
            ],
          ),
        ),
        SectionTitle(title: 'Itens carregados', count: itens.length),
        if (itens.isEmpty)
          const EmptyState(
            text: 'Crie ou busque um item para ele aparecer aqui.',
          )
        else
          ...itens.map(
            (item) => EntityCard(
              title: item.nomeItem,
              subtitle:
                  'ID: ${item.idItem ?? '-'} • Lista: ${item.idLista == 0 ? '-' : item.idLista} • Qtd: ${item.quantidade}',
              icon: item.concluido ? Icons.task_alt_rounded : Icons.radio_button_unchecked_rounded,
              leadingColor: item.concluido ? AppColors.secondary : AppColors.primary,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: item.concluido,
                    activeColor: AppColors.secondary,
                    onChanged: (value) => onAlternarItemConcluido(item, value ?? false),
                  ),
                  IconButton(
                    tooltip: 'Editar',
                    onPressed: () => onEditarItem(item),
                    icon: const Icon(Icons.edit_rounded),
                  ),
                  IconButton(
                    tooltip: 'Deletar',
                    onPressed: () => onDeletarItem(item),
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
