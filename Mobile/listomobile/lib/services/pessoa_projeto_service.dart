import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../models/pessoa_projeto_model.dart';

class PessoaProjetoService {
  final String baseUrl;
  final http.Client _client;

  PessoaProjetoService({this.baseUrl = ApiConfig.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  Future<List<PessoaProjetoModel>> listarConvidados(int idProjeto) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/PessoaProjeto/projeto/$idProjeto'),
    );
    if (response.statusCode != 200) {
      throw Exception(_error('listar convidados', response));
    }
    final data = jsonDecode(response.body);
    if (data is! List) return [];
    return data
        .whereType<Map<String, dynamic>>()
        .map((json) => PessoaProjetoModel.fromJson(json, idProjeto: idProjeto))
        .toList();
  }

  Future<PessoaProjetoModel> adicionarPorEmail({
    required int idPessoaLogada,
    required int idProjeto,
    required String email,
    required int nivelAcesso,
  }) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/PessoaProjeto/adicionar-por-email/$idPessoaLogada'),
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'email': email.trim(),
        'idProjeto': idProjeto,
        'nivelAcesso': nivelAcesso,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_error('adicionar convidado', response));
    }
    return PessoaProjetoModel.fromJson(
      jsonDecode(response.body),
      idProjeto: idProjeto,
    );
  }

  Future<void> alterarNivel({
    required int idPessoaLogada,
    required int idPessoaAlvo,
    required int idProjeto,
    required int novoNivel,
  }) async {
    final response = await _client.put(
      Uri.parse(
        '$baseUrl/PessoaProjeto/alterar-nivel/'
        '$idPessoaLogada/$idPessoaAlvo/$idProjeto/$novoNivel',
      ),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_error('alterar nível', response));
    }
  }

  Future<void> transferirPropriedade({
    required int idDonoAtual,
    required int idNovoDono,
    required int idProjeto,
  }) async {
    final response = await _client.put(
      Uri.parse(
        '$baseUrl/PessoaProjeto/transferir-admin/'
        '$idDonoAtual/$idNovoDono/$idProjeto',
      ),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_error('transferir propriedade', response));
    }
  }

  String _error(String action, http.Response response) {
    return 'Erro ao $action. Código: ${response.statusCode}. '
        'Resposta: ${response.body}';
  }
}
