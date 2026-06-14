import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../models/item_lista_model.dart';

class ItemListaService {
  final String baseUrl;

  ItemListaService({this.baseUrl = ApiConfig.baseUrl});

  Future<ItemListaModel> criarItem(ItemListaModel item) async {
    final response = await http.post(
      Uri.parse('$baseUrl/itemLista'),
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(item.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ItemListaModel.fromJson(jsonDecode(response.body));
    }

    throw Exception(_mensagemErro('criar item', response));
  }


  Future<List<ItemListaModel>> listarTodos() async {
    final response = await http.get(Uri.parse('$baseUrl/itemLista'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((item) => ItemListaModel.fromJson(item))
            .toList();
      }
      return [];
    }

    throw Exception(_mensagemErro('listar', response));
  }

  Future<ItemListaModel?> buscarItemPorId(int idItem) async {
    final response = await http.get(Uri.parse('$baseUrl/itemLista/$idItem'));

    if (response.statusCode == 200) {
      if (response.body.trim().isEmpty || response.body == 'null') return null;
      return ItemListaModel.fromJson(jsonDecode(response.body));
    }

    throw Exception(_mensagemErro('buscar item', response));
  }

  Future<void> atualizarItem(ItemListaModel item) async {
    if (item.idItem == null) {
      throw Exception('Item sem ID não pode ser atualizado.');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/itemLista/${item.idItem}'),
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(item.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 204) return;

    throw Exception(_mensagemErro('atualizar item', response));
  }

  Future<void> deletarItem(int idItem) async {
    final response = await http.delete(Uri.parse('$baseUrl/itemLista/$idItem'));

    if (response.statusCode == 200 || response.statusCode == 204) return;

    throw Exception(_mensagemErro('deletar item', response));
  }

  String _mensagemErro(String acao, http.Response response) {
    return 'Erro ao $acao. Código: ${response.statusCode}. Resposta: ${response.body}';
  }
}
