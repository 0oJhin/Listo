class ListaModel {
  final int? idLista;
  final String nomeLista;
  final bool feito;
  final int idProjeto;

  const ListaModel({
    this.idLista,
    required this.nomeLista,
    required this.idProjeto,
    this.feito = false,
  });

  ListaModel copyWith({
    int? idLista,
    String? nomeLista,
    bool? feito,
    int? idProjeto,
  }) {
    return ListaModel(
      idLista: idLista ?? this.idLista,
      nomeLista: nomeLista ?? this.nomeLista,
      feito: feito ?? this.feito,
      idProjeto: idProjeto ?? this.idProjeto,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idLista != null) 'idLista': idLista,
      'nomeLista': nomeLista,
      'feito': feito,
      'projeto': {'idProjeto': idProjeto},
    };
  }

  factory ListaModel.fromJson(Map<String, dynamic> json) {
    final projeto = json['projeto'];

    return ListaModel(
      idLista: _parseInt(
        json['idLista'] ?? json['id_Lista'] ?? json['id_lista'],
      ),
      nomeLista: (json['nomeLista'] ?? json['nome_lista'] ?? '').toString(),
      feito: _parseBool(json['feito']),
      idProjeto: projeto is Map<String, dynamic>
          ? (_parseInt(
                  projeto['idProjeto'] ??
                      projeto['id_Projeto'] ??
                      projeto['id_projeto'],
                ) ??
                0)
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
