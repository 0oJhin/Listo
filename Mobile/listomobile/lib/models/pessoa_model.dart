class PessoaModel {
  final int? idPessoa;
  final String nomePessoa;
  final String email;
  final String senha;

  const PessoaModel({
    this.idPessoa,
    required this.nomePessoa,
    required this.email,
    required this.senha,
  });

  Map<String, dynamic> toJson() {
    return {
      if (idPessoa != null) 'idPessoa': idPessoa,
      'nomePessoa': nomePessoa,
      'email': email,
      'senha': senha,
    };
  }

  factory PessoaModel.fromJson(Map<String, dynamic> json) {
    return PessoaModel(
      idPessoa: _parseId(json),
      nomePessoa: (json['nomePessoa'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      senha: (json['senha'] ?? '').toString(),
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
}
