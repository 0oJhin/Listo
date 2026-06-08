import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../models/pessoa_model.dart';
import 'login_page.dart';

class HomePage extends StatelessWidget {
  final PessoaModel pessoa;

  const HomePage({
    super.key,
    required this.pessoa,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Listo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Sair',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Center(
        child: Container(
          width: 430,
          padding: const EdgeInsets.all(28),
          margin: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.90),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withOpacity(0.25),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.task_alt_rounded,
                size: 72,
                color: AppColors.secondary,
              ),
              const SizedBox(height: 18),
              Text(
                'Bem-vindo, ${pessoa.nomePessoa}!',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                pessoa.email,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.text.withOpacity(0.7),
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  pessoa.idPessoa == null
                      ? 'ID não retornado pelo backend.'
                      : 'Seu ID de usuário é ${pessoa.idPessoa}.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Aqui depois entram os projetos, listas e itens.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.text.withOpacity(0.7),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
