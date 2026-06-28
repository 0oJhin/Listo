import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../models/pessoa_model.dart';

class PessoaService {
  final String baseUrl;
  final http.Client _client;
  final Duration timeout;

  PessoaService({
    this.baseUrl = ApiConfig.baseUrl,
    http.Client? client,
    this.timeout = const Duration(seconds: 12),
  }) : _client = client ?? http.Client();

  Future<PessoaModel> cadastrarPessoa(PessoaModel pessoa) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/Pessoa'),
            headers: const {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode(pessoa.toJson()),
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data is Map<String, dynamic>) {
          return PessoaModel.fromJson(data);
        }
        throw const FormatException();
      }

      throw PessoaServiceException(
        _mensagemDaResposta(
          response,
          padrao: 'Não foi possível criar sua conta.',
        ),
      );
    } on PessoaServiceException {
      rethrow;
    } on TimeoutException {
      throw PessoaServiceException(
        'O servidor demorou para responder. Verifique se o celular consegue acessar $baseUrl.',
      );
    } on http.ClientException {
      throw const PessoaServiceException(
        'Não foi possível conectar ao servidor. Verifique sua conexão.',
      );
    } on FormatException {
      throw const PessoaServiceException(
        'O servidor retornou uma resposta inválida.',
      );
    } catch (_) {
      throw const PessoaServiceException(
        'Não foi possível criar sua conta. Tente novamente.',
      );
    }
  }

  Future<PessoaModel> login({
    required String email,
    required String senha,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$baseUrl/login'),
            headers: const {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode({'email': email.trim(), 'senha': senha}),
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        if (data is Map<String, dynamic>) {
          return PessoaModel.fromJson(data);
        }
        throw const FormatException();
      }

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const PessoaServiceException('E-mail ou senha inválidos.');
      }

      if (response.statusCode == 404 || response.statusCode == 405) {
        throw const PessoaServiceException(
          'O serviço de login não está disponível no servidor.',
        );
      }

      throw PessoaServiceException(
        _mensagemDaResposta(
          response,
          padrao: 'Não foi possível entrar. Tente novamente.',
        ),
      );
    } on PessoaServiceException {
      rethrow;
    } on TimeoutException {
      throw PessoaServiceException(
        'O servidor demorou para responder. Verifique se o celular consegue acessar $baseUrl.',
      );
    } on http.ClientException {
      throw const PessoaServiceException(
        'Não foi possível conectar ao servidor. Verifique sua conexão.',
      );
    } on FormatException {
      throw const PessoaServiceException(
        'O servidor retornou uma resposta inválida.',
      );
    } catch (_) {
      throw const PessoaServiceException(
        'Não foi possível entrar. Tente novamente.',
      );
    }
  }

  Future<void> tornarPremium(int idPessoa) async {
    try {
      final response = await _client
          .put(Uri.parse('$baseUrl/Pessoa/premium/$idPessoa/$idPessoa'))
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 204) return;

      throw PessoaServiceException(
        _mensagemDaResposta(
          response,
          padrao: 'Não foi possível ativar o plano Premium.',
        ),
      );
    } on PessoaServiceException {
      rethrow;
    } on TimeoutException {
      throw const PessoaServiceException(
        'O servidor demorou para confirmar o pagamento.',
      );
    } on http.ClientException {
      throw const PessoaServiceException(
        'Não foi possível conectar ao servidor.',
      );
    }
  }

  Future<void> cancelarPremium(int idPessoa) async {
    try {
      final response = await _client
          .put(
            Uri.parse('$baseUrl/Pessoa/cancelar-premium/$idPessoa/$idPessoa'),
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 204) return;

      throw PessoaServiceException(
        _mensagemDaResposta(
          response,
          padrao: 'Não foi possível cancelar o plano Premium.',
        ),
      );
    } on PessoaServiceException {
      rethrow;
    } on TimeoutException {
      throw const PessoaServiceException(
        'O servidor demorou para cancelar a assinatura.',
      );
    } on http.ClientException {
      throw const PessoaServiceException(
        'Não foi possível conectar ao servidor.',
      );
    }
  }

  String _mensagemDaResposta(http.Response response, {required String padrao}) {
    if (response.body.trim().isEmpty) return padrao;

    try {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      if (data is Map<String, dynamic>) {
        final mensagem = data['message'] ?? data['mensagem'] ?? data['error'];
        if (mensagem != null && mensagem.toString().trim().isNotEmpty) {
          return mensagem.toString();
        }
      }
    } catch (_) {
      // Usa a mensagem amigável padrão quando a resposta não é JSON.
    }

    return padrao;
  }
}

class PessoaServiceException implements Exception {
  final String mensagem;

  const PessoaServiceException(this.mensagem);

  @override
  String toString() => mensagem;
}
