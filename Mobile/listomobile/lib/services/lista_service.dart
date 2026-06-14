import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../models/lista_model.dart';

class ListaService {
  final String baseUrl;

  ListaService({this.baseUrl = ApiConfig.baseUrl});

  Future<ListaModel> criarLista(ListaModel lista) async {
    final response = await http.post(
      Uri.parse('$baseUrl/Lista'),
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(lista.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ListaModel.fromJson(jsonDecode(response.body));
    }

    throw Exception(_mensagemErro('criar lista', response));
  }


  Future<List<ListaModel>> listarTodos() async {
    final response = await http.get(Uri.parse('$baseUrl/Lista'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map((item) => ListaModel.fromJson(item))
            .toList();
      }
      return [];
    }

    throw Exception(_mensagemErro('listar', response));
  }

  Future<ListaModel?> buscarListaPorId(int idLista) async {
    final response = await http.get(Uri.parse('$baseUrl/Lista/$idLista'));

    if (response.statusCode == 200) {
      if (response.body.trim().isEmpty || response.body == 'null') return null;
      return ListaModel.fromJson(jsonDecode(response.body));
    }

    throw Exception(_mensagemErro('buscar lista', response));
  }

  Future<void> atualizarLista(ListaModel lista) async {
    if (lista.idLista == null) {
      throw Exception('Lista sem ID não pode ser atualizada.');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/Lista/${lista.idLista}'),
      headers: const {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode(lista.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 204) return;

    throw Exception(_mensagemErro('atualizar lista', response));
  }

  Future<void> deletarLista(int idLista) async {
    final response = await http.delete(Uri.parse('$baseUrl/Lista/$idLista'));

    if (response.statusCode == 200 || response.statusCode == 204) return;

    throw Exception(_mensagemErro('deletar lista', response));
  }

  String _mensagemErro(String acao, http.Response response) {
    return 'Erro ao $acao. Código: ${response.statusCode}. Resposta: ${response.body}';
  }
}
