import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../models/projeto_model.dart';

class ProjetoService {
  final String baseUrl;
  final http.Client _client;

  ProjetoService({this.baseUrl = ApiConfig.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  Future<List<ProjetoModel>> listarPorPessoa(int idPessoa) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/PessoaProjeto/pessoa/$idPessoa'),
    );

    if (response.statusCode != 200) {
      throw Exception(_mensagemErro('listar projetos', response));
    }

    final data = jsonDecode(response.body);
    if (data is! List) return [];

    return data
        .whereType<Map<String, dynamic>>()
        .map((vinculo) {
          final projeto = vinculo['projeto'];
          if (projeto is! Map<String, dynamic>) return null;
          return ProjetoModel.fromJson(
            projeto,
          ).copyWith(nivelAcesso: _parseInt(vinculo['nivelAcesso']) ?? 1);
        })
        .whereType<ProjetoModel>()
        .toList();
  }

  Future<ProjetoModel> criarProjetoParaPessoa({
    required ProjetoModel projeto,
    required int idPessoa,
  }) async {
    final responseProjeto = await _client.post(
      Uri.parse('$baseUrl/Projeto'),
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(projeto.toJson()),
    );

    if (responseProjeto.statusCode != 200 &&
        responseProjeto.statusCode != 201) {
      throw Exception(_mensagemErro('criar projeto', responseProjeto));
    }

    final projetoCriado = ProjetoModel.fromJson(
      jsonDecode(responseProjeto.body),
    );

    final responseVinculo = await _client.post(
      Uri.parse('$baseUrl/PessoaProjeto'),
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'pessoa': {'idPessoa': idPessoa},
        'projeto': {'idProjeto': projetoCriado.idProjeto},
        'nivelAcesso': 3,
      }),
    );

    if (responseVinculo.statusCode != 200 &&
        responseVinculo.statusCode != 201) {
      throw Exception(
        _mensagemErro('vincular projeto ao usuário', responseVinculo),
      );
    }

    return projetoCriado.copyWith(nivelAcesso: 3);
  }

  Future<ProjetoModel> criarProjeto(ProjetoModel projeto) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/Projeto'),
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(projeto.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ProjetoModel.fromJson(jsonDecode(response.body));
    }

    throw Exception(_mensagemErro('criar projeto', response));
  }

  Future<List<ProjetoModel>> listarTodos() async {
    final response = await _client.get(Uri.parse('$baseUrl/Projeto'));
    if (response.statusCode != 200) {
      throw Exception(_mensagemErro('listar projetos', response));
    }

    final data = jsonDecode(response.body);
    if (data is! List) return [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(ProjetoModel.fromJson)
        .toList();
  }

  Future<ProjetoModel?> buscarProjetoPorId(int idProjeto) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/Projeto/$idProjeto'),
    );
    if (response.statusCode != 200) {
      throw Exception(_mensagemErro('buscar projeto', response));
    }
    if (response.body.trim().isEmpty || response.body == 'null') return null;
    return ProjetoModel.fromJson(jsonDecode(response.body));
  }

  Future<void> atualizarProjeto(ProjetoModel projeto) async {
    if (projeto.idProjeto == null) {
      throw Exception('Projeto sem ID não pode ser atualizado.');
    }

    final response = await _client.put(
      Uri.parse('$baseUrl/Projeto/${projeto.idProjeto}'),
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(projeto.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_mensagemErro('atualizar projeto', response));
    }
  }

  Future<void> deletarProjeto(int idProjeto) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/Projeto/$idProjeto'),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_mensagemErro('deletar projeto', response));
    }
  }

  Future<void> deletarProjetoComPermissao({
    required int idProjeto,
    required int idPessoa,
  }) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl/Projeto/$idProjeto/pessoa/$idPessoa'),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_mensagemErro('deletar projeto', response));
    }
  }

  String _mensagemErro(String acao, http.Response response) {
    return 'Erro ao $acao. Código: ${response.statusCode}. Resposta: ${response.body}';
  }

  int? _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }
}
