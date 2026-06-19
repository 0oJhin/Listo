import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../models/lista_model.dart';

class ListaService {
  final String baseUrl;
  final http.Client _client;

  ListaService({this.baseUrl = ApiConfig.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  Future<ListaModel> criarLista(ListaModel lista, {int? idPessoa}) async {
    final rota = idPessoa == null ? '/Lista' : '/Lista/pessoa/$idPessoa';
    final response = await _client.post(
      Uri.parse('$baseUrl$rota'),
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(lista.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ListaModel.fromJson(jsonDecode(response.body));
    }

    throw Exception(_mensagemErro('criar lista', response));
  }

  Future<List<ListaModel>> listarPorProjeto(int idProjeto) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/Lista/projeto/$idProjeto'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(
              (item) =>
                  ListaModel.fromJson(item).copyWith(idProjeto: idProjeto),
            )
            .toList();
      }
      return [];
    }

    throw Exception(_mensagemErro('listar listas do projeto', response));
  }

  Future<List<ListaModel>> listarTodos() async {
    final response = await _client.get(Uri.parse('$baseUrl/Lista'));
    if (response.statusCode != 200) {
      throw Exception(_mensagemErro('listar', response));
    }
    final data = jsonDecode(response.body);
    if (data is! List) return [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(ListaModel.fromJson)
        .toList();
  }

  Future<ListaModel?> buscarListaPorId(int idLista) async {
    final response = await _client.get(Uri.parse('$baseUrl/Lista/$idLista'));

    if (response.statusCode == 200) {
      if (response.body.trim().isEmpty || response.body == 'null') return null;
      return ListaModel.fromJson(jsonDecode(response.body));
    }

    throw Exception(_mensagemErro('buscar lista', response));
  }

  Future<void> atualizarLista(ListaModel lista, {int? idPessoa}) async {
    if (lista.idLista == null) {
      throw Exception('Lista sem ID não pode ser atualizada.');
    }

    final rota = idPessoa == null
        ? '/Lista/${lista.idLista}'
        : '/Lista/${lista.idLista}/pessoa/$idPessoa';
    final response = await _client.put(
      Uri.parse('$baseUrl$rota'),
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(lista.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 204) return;

    throw Exception(_mensagemErro('atualizar lista', response));
  }

  Future<void> deletarLista(int idLista, {int? idPessoa}) async {
    final rota = idPessoa == null
        ? '/Lista/$idLista'
        : '/Lista/$idLista/pessoa/$idPessoa';
    final response = await _client.delete(Uri.parse('$baseUrl$rota'));

    if (response.statusCode == 200 || response.statusCode == 204) return;

    throw Exception(_mensagemErro('deletar lista', response));
  }

  String _mensagemErro(String acao, http.Response response) {
    return 'Erro ao $acao. Código: ${response.statusCode}. Resposta: ${response.body}';
  }
}
