import 'package:flutter/material.dart';

import '../components/auth_card.dart';
import '../components/auth_header.dart';
import '../components/custom_text_field.dart';
import '../components/primary_button.dart';
import '../core/app_colors.dart';
import '../models/pessoa_model.dart';
import '../services/pessoa_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();
  final _pessoaService = PessoaService();

  bool _ocultarSenha = true;
  bool _ocultarConfirmarSenha = true;
  bool _carregando = false;

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      final pessoa = PessoaModel(
        nomePessoa: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        senha: _senhaController.text,
      );

      final pessoaCadastrada = await _pessoaService.cadastrarPessoa(pessoa);

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Cadastro realizado'),
          content: Text(
            pessoaCadastrada.idPessoa == null
                ? 'Conta criada com sucesso.'
                : 'Conta criada com sucesso. Seu ID de usuário é ${pessoaCadastrada.idPessoa}.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.pop(context, pessoaCadastrada);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_limparMensagemErro(error)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _carregando = false);
      }
    }
  }

  String _limparMensagemErro(Object error) {
    final mensagem = error.toString().replaceFirst('Exception: ', '');

    if (mensagem.contains('XMLHttpRequest')) {
      return 'Não foi possível acessar o backend. Verifique se ele está rodando em http://localhost:8080 e se o CORS está liberado.';
    }

    return mensagem;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        elevation: 0,
        title: const Text(
          'Cadastro',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: AuthCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AuthHeader(
                        icon: Icons.person_add_alt_rounded,
                        title: 'Criar conta',
                        subtitle: 'Preencha seus dados para começar.',
                      ),
                      const SizedBox(height: 28),
                      CustomTextField(
                        controller: _nomeController,
                        label: 'Nome',
                        hint: 'Digite seu nome',
                        icon: Icons.badge_outlined,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe seu nome';
                          }
                          if (value.trim().length < 3) {
                            return 'Nome muito curto';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email',
                        hint: 'Digite seu email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe seu email';
                          }
                          if (!value.contains('@')) {
                            return 'Informe um email válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _senhaController,
                        label: 'Senha',
                        hint: 'Digite sua senha',
                        icon: Icons.lock_outline_rounded,
                        obscureText: _ocultarSenha,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() => _ocultarSenha = !_ocultarSenha);
                          },
                          icon: Icon(
                            _ocultarSenha
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe sua senha';
                          }
                          if (value.length < 4) {
                            return 'Senha muito curta';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: _confirmarSenhaController,
                        label: 'Confirmar senha',
                        hint: 'Repita sua senha',
                        icon: Icons.lock_reset_rounded,
                        obscureText: _ocultarConfirmarSenha,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(
                              () => _ocultarConfirmarSenha =
                                  !_ocultarConfirmarSenha,
                            );
                          },
                          icon: Icon(
                            _ocultarConfirmarSenha
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Confirme sua senha';
                          }
                          if (value != _senhaController.text) {
                            return 'As senhas não coincidem';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        text: 'Cadastrar',
                        icon: Icons.person_add_alt_rounded,
                        loading: _carregando,
                        onPressed: _cadastrar,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
