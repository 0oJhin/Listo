import 'pessoa_model.dart';

class PessoaProjetoModel {
  final int? idPessoaProjeto;
  final int nivelAcesso;
  final PessoaModel pessoa;
  final int idProjeto;

  const PessoaProjetoModel({
    this.idPessoaProjeto,
    required this.nivelAcesso,
    required this.pessoa,
    required this.idProjeto,
  });

  PessoaProjetoModel copyWith({int? nivelAcesso}) {
    return PessoaProjetoModel(
      idPessoaProjeto: idPessoaProjeto,
      nivelAcesso: nivelAcesso ?? this.nivelAcesso,
      pessoa: pessoa,
      idProjeto: idProjeto,
    );
  }

  factory PessoaProjetoModel.fromJson(
    Map<String, dynamic> json, {
    required int idProjeto,
  }) {
    final pessoa = json['pessoa'];
    return PessoaProjetoModel(
      idPessoaProjeto: _parseInt(
        json['idPessoaProjeto'] ??
            json['id_PessoaProjeto'] ??
            json['id_pessoa_projeto'],
      ),
      nivelAcesso: _parseInt(json['nivelAcesso']) ?? 1,
      pessoa: pessoa is Map<String, dynamic>
          ? PessoaModel.fromJson(pessoa)
          : const PessoaModel(nomePessoa: '', email: '', senha: ''),
      idProjeto: idProjeto,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}
