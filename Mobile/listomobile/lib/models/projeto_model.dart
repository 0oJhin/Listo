class ProjetoModel {
  final int? idProjeto;
  final String nomeProjeto;

  const ProjetoModel({
    this.idProjeto,
    required this.nomeProjeto,
  });

  ProjetoModel copyWith({
    int? idProjeto,
    String? nomeProjeto,
  }) {
    return ProjetoModel(
      idProjeto: idProjeto ?? this.idProjeto,
      nomeProjeto: nomeProjeto ?? this.nomeProjeto,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idProjeto != null) 'idProjeto': idProjeto,
      'nomeProjeto': nomeProjeto,
    };
  }

  factory ProjetoModel.fromJson(Map<String, dynamic> json) {
    return ProjetoModel(
      idProjeto: _parseInt(
        json['idProjeto'] ?? json['id_Projeto'] ?? json['id_projeto'],
      ),
      nomeProjeto: (json['nomeProjeto'] ?? json['nome_projeto'] ?? '').toString(),
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
