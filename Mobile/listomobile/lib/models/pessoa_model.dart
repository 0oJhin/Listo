class PessoaModel {
  final int? idPessoa;
  final String nomePessoa;
  final String email;
  final String senha;
  final bool premium;

  const PessoaModel({
    this.idPessoa,
    required this.nomePessoa,
    required this.email,
    required this.senha,
    this.premium = false,
  });

  PessoaModel copyWith({
    int? idPessoa,
    String? nomePessoa,
    String? email,
    String? senha,
    bool? premium,
  }) {
    return PessoaModel(
      idPessoa: idPessoa ?? this.idPessoa,
      nomePessoa: nomePessoa ?? this.nomePessoa,
      email: email ?? this.email,
      senha: senha ?? this.senha,
      premium: premium ?? this.premium,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idPessoa != null) 'idPessoa': idPessoa,
      'nomePessoa': nomePessoa,
      'email': email,
      'senha': senha,
      'premium': premium,
    };
  }

  factory PessoaModel.fromJson(Map<String, dynamic> json) {
    return PessoaModel(
      idPessoa: _parseId(json),
      nomePessoa: (json['nomePessoa'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      senha: (json['senha'] ?? '').toString(),
      premium: _parseBool(json['premium']),
    );
  }

  static int? _parseId(Map<String, dynamic> json) {
    final dynamic value =
        json['idPessoa'] ??
        json['id_Pessoa'] ??
        json['id_pessoa'] ??
        json['id_Pesssoa'];

    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    return value.toString().toLowerCase() == 'true';
  }
}
