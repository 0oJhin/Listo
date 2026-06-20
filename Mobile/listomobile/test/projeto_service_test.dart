import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:listomobile/models/projeto_model.dart';
import 'package:listomobile/services/projeto_service.dart';

void main() {
  test('lista projetos pelos vínculos da pessoa', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/PessoaProjeto/pessoa/1');
      return http.Response(
        jsonEncode([
          {
            'nivelAcesso': 3,
            'projeto': {'idProjeto': 1, 'nomeProjeto': 'Projeto do João'},
          },
        ]),
        200,
      );
    });

    final service = ProjetoService(baseUrl: 'http://localhost', client: client);
    final projetos = await service.listarPorPessoa(1);

    expect(projetos.single.nomeProjeto, 'Projeto do João');
  });

  test('cria projeto e vincula o criador como nível 3', () async {
    var requisicao = 0;
    final client = MockClient((request) async {
      requisicao++;
      if (requisicao == 1) {
        expect(request.url.path, '/Projeto');
        return http.Response(
          jsonEncode({'idProjeto': 7, 'nomeProjeto': 'Novo projeto'}),
          201,
        );
      }

      expect(request.url.path, '/PessoaProjeto');
      final body = jsonDecode(request.body);
      expect(body['pessoa']['idPessoa'], 1);
      expect(body['projeto']['idProjeto'], 7);
      expect(body['nivelAcesso'], 3);
      return http.Response('{}', 201);
    });

    final service = ProjetoService(baseUrl: 'http://localhost', client: client);
    await service.criarProjetoParaPessoa(
      projeto: const ProjetoModel(nomeProjeto: 'Novo projeto'),
      idPessoa: 1,
    );

    expect(requisicao, 2);
  });

  test('deleta projeto usando a permissão da pessoa', () async {
    final client = MockClient((request) async {
      expect(request.method, 'DELETE');
      expect(request.url.path, '/Projeto/7/pessoa/1');
      return http.Response('', 204);
    });

    final service = ProjetoService(baseUrl: 'http://localhost', client: client);
    await service.deletarProjetoComPermissao(idProjeto: 7, idPessoa: 1);
  });
}
