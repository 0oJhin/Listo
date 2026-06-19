import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../models/item_lista_model.dart';

class ItemListaService {
  final String baseUrl;
  final http.Client _client;

  ItemListaService({this.baseUrl = ApiConfig.baseUrl, http.Client? client})
    : _client = client ?? http.Client();

  Future<ItemListaModel> criarItem(ItemListaModel item, {int? idPessoa}) async {
    final rota = idPessoa == null
        ? '/itemLista'
        : '/itemLista/pessoa/$idPessoa';
    final response = await _client.post(
      Uri.parse('$baseUrl$rota'),
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(item.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ItemListaModel.fromJson(jsonDecode(response.body));
    }

    throw Exception(_mensagemErro('criar item', response));
  }

  Future<List<ItemListaModel>> listarPorLista(int idLista) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/itemLista/lista/$idLista'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(
              (item) =>
                  ItemListaModel.fromJson(item).copyWith(idLista: idLista),
            )
            .toList();
      }
      return [];
    }

    throw Exception(_mensagemErro('listar itens', response));
  }

  Future<List<ItemListaModel>> listarTodos() async {
    final response = await _client.get(Uri.parse('$baseUrl/itemLista'));
    if (response.statusCode != 200) {
      throw Exception(_mensagemErro('listar', response));
    }
    final data = jsonDecode(response.body);
    if (data is! List) return [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(ItemListaModel.fromJson)
        .toList();
  }

  Future<ItemListaModel?> buscarItemPorId(int idItem) async {
    final response = await _client.get(Uri.parse('$baseUrl/itemLista/$idItem'));

    if (response.statusCode == 200) {
      if (response.body.trim().isEmpty || response.body == 'null') return null;
      return ItemListaModel.fromJson(jsonDecode(response.body));
    }

    throw Exception(_mensagemErro('buscar item', response));
  }

  Future<void> atualizarItem(ItemListaModel item, {int? idPessoa}) async {
    if (item.idItem == null) {
      throw Exception('Item sem ID não pode ser atualizado.');
    }

    final rota = idPessoa == null
        ? '/itemLista/${item.idItem}'
        : '/itemLista/${item.idItem}/pessoa/$idPessoa';
    final response = await _client.put(
      Uri.parse('$baseUrl$rota'),
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(item.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 204) return;

    throw Exception(_mensagemErro('atualizar item', response));
  }

  Future<void> alterarConcluido({
    required ItemListaModel item,
    required int idPessoa,
  }) async {
    if (item.idItem == null) throw Exception('Item sem ID.');
    final response = await _client.put(
      Uri.parse('$baseUrl/itemLista/${item.idItem}/concluido/$idPessoa'),
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(item.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 204) return;
    throw Exception(_mensagemErro('alterar conclusão', response));
  }

  Future<void> deletarItem(int idItem, {int? idPessoa}) async {
    final rota = idPessoa == null
        ? '/itemLista/$idItem'
        : '/itemLista/$idItem/pessoa/$idPessoa';
    final response = await _client.delete(Uri.parse('$baseUrl$rota'));

    if (response.statusCode == 200 || response.statusCode == 204) return;

    throw Exception(_mensagemErro('deletar item', response));
  }

  String _mensagemErro(String acao, http.Response response) {
    return 'Erro ao $acao. Código: ${response.statusCode}. Resposta: ${response.body}';
  }
}
