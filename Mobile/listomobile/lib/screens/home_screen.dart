import 'package:flutter/material.dart';

import '../components/section_title.dart';
import '../main.dart';
import '../models/pessoa_model.dart';
import '../models/projeto_model.dart';
import '../services/projeto_service.dart';
import 'home/widgets/add_project_card.dart';
import 'home/widgets/create_project_dialog.dart';
import 'home/widgets/empty_projects_prompt.dart';
import 'home/widgets/home_header.dart';
import 'home/widgets/home_shortcut_button.dart';
import 'home/widgets/project_card.dart';
import 'home/widgets/settings_dialog.dart';
import 'login_screen.dart';
import 'project/project_screen.dart';

class HomeScreen extends StatefulWidget {
  final PessoaModel pessoa;

  const HomeScreen({super.key, required this.pessoa});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = ProjetoService();
  final List<ProjetoModel> _projetos = [];
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _carregarProjetos();
  }

  Future<void> _carregarProjetos() async {
    final idPessoa = widget.pessoa.idPessoa;
    if (idPessoa == null) return;

    setState(() => _carregando = true);
    try {
      final projetos = await _service.listarPorPessoa(idPessoa);
      if (!mounted) return;
      setState(() {
        _projetos
          ..clear()
          ..addAll(projetos.reversed);
      });
    } catch (error) {
      if (mounted) _mensagem(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _abrirNovoProjeto() async {
    final nome = await showDialog<String>(
      context: context,
      builder: (_) => const CreateProjectDialog(),
    );
    if (nome == null || !mounted) return;

    final idPessoa = widget.pessoa.idPessoa;
    if (idPessoa == null) {
      _mensagem('Não foi possível identificar o usuário.');
      return;
    }

    setState(() => _carregando = true);
    try {
      await _service.criarProjetoParaPessoa(
        projeto: ProjetoModel(nomeProjeto: nome),
        idPessoa: idPessoa,
      );
      await _carregarProjetos();
      if (mounted) _mensagem('Projeto criado com sucesso.');
    } catch (error) {
      if (mounted) _mensagem(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  void _mensagem(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  void _abrirProjeto(ProjetoModel projeto) {
    final idPessoa = widget.pessoa.idPessoa;
    if (idPessoa == null || projeto.idProjeto == null) {
      _mensagem('Não foi possível abrir este projeto.');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectScreen(projeto: projeto, idPessoa: idPessoa),
      ),
    );
  }

  Future<void> _abrirConfiguracoes() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final app = ListoApp.of(context);
        return SettingsDialog(
          darkModeEnabled: app.darkModeEnabled,
          onDarkModeChanged: app.setDarkMode,
          onLogout: () {
            Navigator.pop(dialogContext);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (_) => false,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final recentes = _projetos.take(3).toList();
    final semProjetos = !_carregando && _projetos.isEmpty;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _carregarProjetos,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: HomeHeader(userName: widget.pessoa.nomePessoa),
              ),
              if (_carregando)
                const SliverToBoxAdapter(
                  child: LinearProgressIndicator(minHeight: 3),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      HomeShortcutButton(
                        icon: Icons.home_outlined,
                        label: 'Home',
                        onPressed: _carregarProjetos,
                      ),
                      HomeShortcutButton(
                        icon: Icons.add,
                        label: 'Adicionar',
                        onPressed: _abrirNovoProjeto,
                      ),
                      HomeShortcutButton(
                        icon: Icons.settings_outlined,
                        label: 'Configurações',
                        onPressed: _abrirConfiguracoes,
                      ),
                    ],
                  ),
                ),
              ),
              if (semProjetos)
                SliverToBoxAdapter(
                  child: EmptyProjectsPrompt(onCreate: _abrirNovoProjeto),
                ),
              if (!semProjetos) ...[
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 28, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: SectionTitle(title: 'Recentes'),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: SizedBox(
                      height: 115,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: recentes.length,
                        separatorBuilder: (_, index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (_, index) => SizedBox(
                          width: 150,
                          child: ProjectCard(
                            name: recentes[index].nomeProjeto,
                            color: _corProjeto(index),
                            onTap: () => _abrirProjeto(recentes[index]),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  sliver: SliverToBoxAdapter(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _carregarProjetos,
                        child: const Text('Ver todos os projetos recentes'),
                      ),
                    ),
                  ),
                ),
                const SliverPadding(
                  padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
                  sliver: SliverToBoxAdapter(
                    child: SectionTitle(title: 'Meus projetos'),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 210,
                          mainAxisExtent: 130,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                    delegate: SliverChildBuilderDelegate((_, index) {
                      if (index == _projetos.length) {
                        return AddProjectCard(onPressed: _abrirNovoProjeto);
                      }
                      return ProjectCard(
                        name: _projetos[index].nomeProjeto,
                        color: _corProjeto(index),
                        onTap: () => _abrirProjeto(_projetos[index]),
                      );
                    }, childCount: _projetos.length + 1),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _corProjeto(int index) {
    return index.isEven ? const Color(0xFFC5DD64) : const Color(0xFF829764);
  }
}
