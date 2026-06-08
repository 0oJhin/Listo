import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../models/pessoa_model.dart';

class PessoaService {
  final String baseUrl;

  PessoaService({this.baseUrl = ApiConfig.baseUrl});

  Future<PessoaModel> cadastrarPessoa(PessoaModel pessoa) async {
    final uri = Uri.parse('$baseUrl/Pessoa');

    final response = await http.post(
      uri,
      headers: const {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(pessoa.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return PessoaModel.fromJson(data);
    }

    throw Exception(
      'Erro ao cadastrar pessoa. Código: ${response.statusCode}. Resposta: ${response.body}',
    );
  }

  Future<PessoaModel?> buscarPessoaPorId(int idPessoa) async {
    final uri = Uri.parse('$baseUrl/Pessoa/$idPessoa');

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      if (response.body.trim().isEmpty || response.body == 'null') {
        return null;
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      return PessoaModel.fromJson(data);
    }

    throw Exception(
      'Erro ao buscar pessoa. Código: ${response.statusCode}. Resposta: ${response.body}',
    );
  }

  /// Login temporário usando somente o backend atual.
  ///
  /// O backend enviado possui:
  /// - POST /Pessoa
  /// - GET /Pessoa/{id}
  ///
  /// Ele não possui busca por email/usuário nem endpoint /login.
  /// Por isso, sem mexer no backend, o login real só consegue validar usando ID + senha.
  Future<PessoaModel> loginComBackendAtual({
    required String usuario,
    required String senha,
  }) async {
    final int? idPessoa = int.tryParse(usuario.trim());

    if (idPessoa == null) {
      throw Exception(
        'O backend atual não possui login por usuário/email. Use o ID da pessoa como usuário ou peça uma rota de login ao backend.',
      );
    }

    final pessoa = await buscarPessoaPorId(idPessoa);

    if (pessoa == null) {
      throw Exception('Usuário não encontrado.');
    }

    if (pessoa.senha != senha) {
      throw Exception('Senha incorreta.');
    }

    return pessoa;
  }
}
