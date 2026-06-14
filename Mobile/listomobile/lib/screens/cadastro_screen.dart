import 'package:flutter/material.dart';

import '../components/auth_card.dart';
import '../components/auth_header.dart';
import '../components/custom_text_field.dart';
import '../components/primary_button.dart';
import '../core/app_colors.dart';
import '../models/pessoa_model.dart';
import '../services/pessoa_service.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeUsuarioController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _pessoaService = PessoaService();

  bool _ocultarSenha = true;
  bool _carregando = false;

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      final pessoa = await _pessoaService.cadastrarPessoa(
        PessoaModel(
          nomePessoa: _nomeUsuarioController.text.trim(),
          email: _emailController.text.trim(),
          senha: _senhaController.text,
        ),
      );

      if (!mounted) return;
      Navigator.pop(context, pessoa);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  void dispose() {
    _nomeUsuarioController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.text,
        title: const Text('Cadastro'),
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
                        subtitle: 'Informe seus dados para começar.',
                      ),
                      const SizedBox(height: 28),
                      CustomTextField(
                        controller: _nomeUsuarioController,
                        label: 'Nome de usuário',
                        hint: 'Escolha seu nome de usuário',
                        icon: Icons.person_outline_rounded,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Informe seu nome de usuário';
                          }
                          if (value.trim().length < 3) {
                            return 'Use pelo menos 3 caracteres';
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
                          final email = value?.trim() ?? '';
                          if (email.isEmpty) return 'Informe seu email';
                          if (!email.contains('@') || !email.contains('.')) {
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
                          if (value == null || value.isEmpty) {
                            return 'Informe sua senha';
                          }
                          if (value.length < 4) {
                            return 'Use pelo menos 4 caracteres';
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
