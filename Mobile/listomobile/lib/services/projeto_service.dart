import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../models/projeto_model.dart';

class ProjetoService {
  final String baseUrl;

  ProjetoService({this.baseUrl = ApiConfig.baseUrl});

  Future<ProjetoModel> criarProjeto(ProjetoModel projeto) async {
    final response = await http.post(
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
    final response = await http.get(Uri.parse('$baseUrl/Projeto'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((item) => ProjetoModel.fromJson(item))
            .toList();
      }
      return [];
    }

    throw Exception(_mensagemErro('listar', response));
  }

  Future<ProjetoModel?> buscarProjetoPorId(int idProjeto) async {
    final response = await http.get(Uri.parse('$baseUrl/Projeto/$idProjeto'));

    if (response.statusCode == 200) {
      if (response.body.trim().isEmpty || response.body == 'null') return null;
      return ProjetoModel.fromJson(jsonDecode(response.body));
    }

    throw Exception(_mensagemErro('buscar projeto', response));
  }

  Future<void> atualizarProjeto(ProjetoModel projeto) async {
    if (projeto.idProjeto == null) {
      throw Exception('Projeto sem ID não pode ser atualizado.');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/Projeto/${projeto.idProjeto}'),
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(projeto.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 204) return;

    throw Exception(_mensagemErro('atualizar projeto', response));
  }

  Future<void> deletarProjeto(int idProjeto) async {
    final response = await http.delete(Uri.parse('$baseUrl/Projeto/$idProjeto'));

    if (response.statusCode == 200 || response.statusCode == 204) return;

    throw Exception(_mensagemErro('deletar projeto', response));
  }

  String _mensagemErro(String acao, http.Response response) {
    return 'Erro ao $acao. Código: ${response.statusCode}. Resposta: ${response.body}';
  }
}
