class ProjetoModel {
  final int? idProjeto;
  final String nomeProjeto;
  final int nivelAcesso;

  const ProjetoModel({
    this.idProjeto,
    required this.nomeProjeto,
    this.nivelAcesso = 3,
  });

  ProjetoModel copyWith({
    int? idProjeto,
    String? nomeProjeto,
    int? nivelAcesso,
  }) {
    return ProjetoModel(
      idProjeto: idProjeto ?? this.idProjeto,
      nomeProjeto: nomeProjeto ?? this.nomeProjeto,
      nivelAcesso: nivelAcesso ?? this.nivelAcesso,
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
      nomeProjeto: (json['nomeProjeto'] ?? json['nome_projeto'] ?? '')
          .toString(),
      nivelAcesso: _parseInt(json['nivelAcesso']) ?? 3,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
