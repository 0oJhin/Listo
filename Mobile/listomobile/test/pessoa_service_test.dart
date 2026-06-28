import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:listomobile/models/pessoa_model.dart';
import 'package:listomobile/services/pessoa_service.dart';

void main() {
  test('login envia email e senha para POST /login', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.toString(), 'http://api.test/login');
      expect(jsonDecode(request.body), {
        'email': 'joao@email.com',
        'senha': '1234',
      });

      return http.Response(
        jsonEncode({
          'idPessoa': 1,
          'nomePessoa': 'João',
          'email': 'joao@email.com',
          'senha': '1234',
          'premium': true,
        }),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    final pessoa = await PessoaService(
      baseUrl: 'http://api.test',
      client: client,
    ).login(email: ' joao@email.com ', senha: '1234');

    expect(pessoa.idPessoa, 1);
    expect(pessoa.email, 'joao@email.com');
    expect(pessoa.premium, isTrue);
  });

  test(
    'login apresenta mensagem amigável para credenciais inválidas',
    () async {
      final client = MockClient((_) async => http.Response('', 401));

      final login = PessoaService(
        baseUrl: 'http://api.test',
        client: client,
      ).login(email: 'joao@email.com', senha: 'errada');

      expect(
        login,
        throwsA(
          isA<PessoaServiceException>().having(
            (error) => error.mensagem,
            'mensagem',
            'E-mail ou senha inválidos.',
          ),
        ),
      );
    },
  );

  test(
    'cadastro encerra carregamento quando o servidor não responde',
    () async {
      final client = MockClient((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return http.Response('{}', 200);
      });

      final cadastro =
          PessoaService(
            baseUrl: 'http://api.test',
            client: client,
            timeout: const Duration(milliseconds: 1),
          ).cadastrarPessoa(
            const PessoaModel(
              nomePessoa: 'João',
              email: 'joao@email.com',
              senha: '1234',
            ),
          );

      expect(
        cadastro,
        throwsA(
          isA<PessoaServiceException>().having(
            (error) => error.mensagem,
            'mensagem',
            contains('http://api.test'),
          ),
        ),
      );
    },
  );

  test('ativa o plano premium da própria pessoa', () async {
    final client = MockClient((request) async {
      expect(request.method, 'PUT');
      expect(request.url.path, '/Pessoa/premium/1/1');
      return http.Response('', 204);
    });

    await PessoaService(
      baseUrl: 'http://api.test',
      client: client,
    ).tornarPremium(1);
  });

  test('cancela o plano premium da própria pessoa', () async {
    final client = MockClient((request) async {
      expect(request.method, 'PUT');
      expect(request.url.path, '/Pessoa/cancelar-premium/1/1');
      return http.Response('', 204);
    });

    await PessoaService(
      baseUrl: 'http://api.test',
      client: client,
    ).cancelarPremium(1);
  });
}
