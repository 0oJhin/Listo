import 'package:flutter/material.dart';

import '../components/auth_card.dart';
import '../components/auth_header.dart';
import '../components/custom_text_field.dart';
import '../components/primary_button.dart';
import '../core/app_colors.dart';
import '../models/pessoa_model.dart';
import '../services/pessoa_service.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioController = TextEditingController();
  final _senhaController = TextEditingController();
  final _pessoaService = PessoaService();

  bool _lembrarDeMim = false;
  bool _ocultarSenha = true;
  bool _carregando = false;

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      final pessoa = await _pessoaService.loginComBackendAtual(
        usuario: _usuarioController.text,
        senha: _senhaController.text,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(pessoa: pessoa),
        ),
      );
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

  Future<void> _irParaCadastro() async {
    final PessoaModel? pessoaCadastrada = await Navigator.push<PessoaModel>(
      context,
      MaterialPageRoute(
        builder: (_) => const RegisterPage(),
      ),
    );

    if (pessoaCadastrada != null && pessoaCadastrada.idPessoa != null) {
      _usuarioController.text = pessoaCadastrada.idPessoa.toString();
      _senhaController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cadastro criado. Use o ID ${pessoaCadastrada.idPessoa} como usuário para entrar.',
          ),
        ),
      );
    }
  }

  void _esqueciSenha() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recuperação de senha será implementada depois.'),
      ),
    );
  }

  String _limparMensagemErro(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  void dispose() {
    _usuarioController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                        icon: Icons.checklist_rounded,
                        title: 'Listo',
                        subtitle:
                            'Organize suas listas e projetos de forma simples.',
                      ),
                      const SizedBox(height: 32),
                      CustomTextField(
                        controller: _usuarioController,
                        label: 'Usuário',
                        hint: 'Digite seu ID de usuário',
                        icon: Icons.person_outline_rounded,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe seu usuário';
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
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Checkbox(
                            value: _lembrarDeMim,
                            activeColor: AppColors.secondary,
                            onChanged: (value) {
                              setState(() {
                                _lembrarDeMim = value ?? false;
                              });
                            },
                          ),
                          const Text(
                            'Lembrar de mim',
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: _esqueciSenha,
                            child: const Text(
                              'Esqueci minha senha',
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      PrimaryButton(
                        text: 'Entrar',
                        icon: Icons.login_rounded,
                        loading: _carregando,
                        onPressed: _entrar,
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Não tem conta?',
                            style: TextStyle(
                              color: AppColors.text.withOpacity(0.7),
                            ),
                          ),
                          TextButton(
                            onPressed: _irParaCadastro,
                            child: const Text(
                              'Cadastre-se',
                              style: TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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
