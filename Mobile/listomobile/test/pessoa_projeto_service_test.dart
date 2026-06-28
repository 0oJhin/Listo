import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:listomobile/services/pessoa_projeto_service.dart';

void main() {
  test('adiciona convidado por e-mail com nível 2', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/PessoaProjeto/adicionar-por-email/1');
      expect(jsonDecode(request.body), {
        'email': 'convidado@email.com',
        'idProjeto': 7,
        'nivelAcesso': 2,
      });
      return http.Response(
        jsonEncode({
          'idPessoaProjeto': 9,
          'nivelAcesso': 2,
          'pessoa': {
            'idPessoa': 3,
            'nomePessoa': 'Convidado',
            'email': 'convidado@email.com',
            'premium': false,
          },
        }),
        201,
      );
    });

    final member =
        await PessoaProjetoService(
          baseUrl: 'http://api.test',
          client: client,
        ).adicionarPorEmail(
          idPessoaLogada: 1,
          idProjeto: 7,
          email: 'convidado@email.com',
          nivelAcesso: 2,
        );

    expect(member.nivelAcesso, 2);
    expect(member.pessoa.idPessoa, 3);
  });

  test('transfere a propriedade para outro convidado', () async {
    final client = MockClient((request) async {
      expect(request.method, 'PUT');
      expect(request.url.path, '/PessoaProjeto/transferir-admin/1/3/7');
      return http.Response('', 204);
    });

    await PessoaProjetoService(
      baseUrl: 'http://api.test',
      client: client,
    ).transferirPropriedade(idDonoAtual: 1, idNovoDono: 3, idProjeto: 7);
  });
}
