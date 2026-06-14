class ItemListaModel {
  final int? idItem;
  final String nomeItem;
  final int quantidade;
  final bool concluido;
  final bool isTarefa;
  final int idLista;

  const ItemListaModel({
    this.idItem,
    required this.nomeItem,
    required this.idLista,
    this.quantidade = 1,
    this.concluido = false,
    this.isTarefa = true,
  });

  ItemListaModel copyWith({
    int? idItem,
    String? nomeItem,
    int? quantidade,
    bool? concluido,
    bool? isTarefa,
    int? idLista,
  }) {
    return ItemListaModel(
      idItem: idItem ?? this.idItem,
      nomeItem: nomeItem ?? this.nomeItem,
      quantidade: quantidade ?? this.quantidade,
      concluido: concluido ?? this.concluido,
      isTarefa: isTarefa ?? this.isTarefa,
      idLista: idLista ?? this.idLista,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idItem != null) 'id_Item': idItem,
      'nomeItem': nomeItem,
      'quantidade': isTarefa ? 1 : quantidade,
      'concluido': concluido,
      'isTarefa': isTarefa,
      'lista': {'idLista': idLista},
    };
  }

  factory ItemListaModel.fromJson(Map<String, dynamic> json) {
    final lista = json['lista'];

    return ItemListaModel(
      idItem: _parseInt(
        json['id_Item'] ?? json['idItem'] ?? json['id_item'] ?? json['id'],
      ),
      nomeItem: (json['nomeItem'] ?? json['nome_item'] ?? '').toString(),
      quantidade: _parseInt(json['quantidade']) ?? 1,
      concluido: _parseBool(json['concluido']),
      isTarefa: _parseBool(json['isTarefa'] ?? json['tarefa']),
      idLista: lista is Map<String, dynamic>
          ? (_parseInt(lista['idLista'] ?? lista['id_Lista'] ?? lista['id_lista']) ?? 0)
          : 0,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    return value.toString().toLowerCase() == 'true';
  }
}
