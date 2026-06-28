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
import 'home/widgets/project_limit_dialog.dart';
import 'home/widgets/project_options_sheet.dart';
import 'home/widgets/rename_project_dialog.dart';
import 'home/widgets/settings_dialog.dart';
import 'login_screen.dart';
import 'plans/plan_screen.dart';
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
  late PessoaModel _pessoa = widget.pessoa;
  bool _carregando = false;

  @override
  void initState() {
    super.initState();
    _carregarProjetos();
  }

  Future<void> _carregarProjetos() async {
    final idPessoa = _pessoa.idPessoa;
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
    if (_carregando) {
      _mensagem('Aguarde o carregamento dos seus projetos.');
      return;
    }

    final ownedProjects = _projetos.where(
      (project) => project.nivelAcesso == 3,
    );
    if (!_pessoa.premium && ownedProjects.isNotEmpty) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => ProjectLimitDialog(
          onManagePlan: () {
            Navigator.pop(dialogContext);
            _abrirPlanos();
          },
        ),
      );
      return;
    }

    final nome = await showDialog<String>(
      context: context,
      builder: (_) => const CreateProjectDialog(),
    );
    if (nome == null || !mounted) return;

    final idPessoa = _pessoa.idPessoa;
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

  Future<void> _abrirProjeto(ProjetoModel projeto) async {
    final idPessoa = _pessoa.idPessoa;
    if (idPessoa == null || projeto.idProjeto == null) {
      _mensagem('Não foi possível abrir este projeto.');
      return;
    }
    final updatedProject = await Navigator.push<ProjetoModel>(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectScreen(projeto: projeto, idPessoa: idPessoa),
      ),
    );
    if (updatedProject != null && mounted) {
      setState(() {
        final index = _projetos.indexWhere(
          (item) => item.idProjeto == updatedProject.idProjeto,
        );
        if (index >= 0) _projetos[index] = updatedProject;
      });
    }
  }

  Future<void> _abrirOpcoesProjeto(ProjetoModel projeto) async {
    final action = await showModalBottomSheet<ProjectAction>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => ProjectOptionsSheet(
        projectName: projeto.nomeProjeto,
        canRename: projeto.nivelAcesso >= 2,
        canDelete: projeto.nivelAcesso == 3,
      ),
    );

    if (!mounted || action == null) return;
    switch (action) {
      case ProjectAction.rename:
        await _renomearProjeto(projeto);
        break;
      case ProjectAction.delete:
        await _apagarProjeto(projeto);
        break;
    }
  }

  Future<void> _renomearProjeto(ProjetoModel projeto) async {
    final novoNome = await showDialog<String>(
      context: context,
      builder: (_) => RenameProjectDialog(currentName: projeto.nomeProjeto),
    );
    if (novoNome == null || novoNome == projeto.nomeProjeto || !mounted) return;

    final atualizado = projeto.copyWith(nomeProjeto: novoNome);
    setState(() => _carregando = true);
    try {
      await _service.atualizarProjeto(atualizado);
      if (!mounted) return;
      setState(() {
        final index = _projetos.indexWhere(
          (item) => item.idProjeto == projeto.idProjeto,
        );
        if (index >= 0) _projetos[index] = atualizado;
      });
      _mensagem('Nome do projeto alterado.');
    } catch (error) {
      if (mounted) _mensagem(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _apagarProjeto(ProjetoModel projeto) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Theme.of(dialogContext).colorScheme.error,
        ),
        title: const Text('Apagar projeto?'),
        content: Text(
          'Esta ação apagará "${projeto.nomeProjeto}", suas listas e seus itens. '
          'Não será possível desfazer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Apagar projeto'),
          ),
        ],
      ),
    );
    if (confirmado != true || !mounted) return;

    final idProjeto = projeto.idProjeto;
    final idPessoa = _pessoa.idPessoa;
    if (idProjeto == null || idPessoa == null) {
      _mensagem('Não foi possível identificar o projeto ou usuário.');
      return;
    }

    setState(() => _carregando = true);
    try {
      await _service.deletarProjetoComPermissao(
        idProjeto: idProjeto,
        idPessoa: idPessoa,
      );
      if (!mounted) return;
      setState(() {
        _projetos.removeWhere((item) => item.idProjeto == idProjeto);
      });
      _mensagem('Projeto apagado.');
    } catch (error) {
      if (mounted) _mensagem(error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _abrirConfiguracoes() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final app = ListoApp.of(context);
        return SettingsDialog(
          darkModeEnabled: app.darkModeEnabled,
          onDarkModeChanged: app.setDarkMode,
          onManagePlan: () {
            Navigator.pop(dialogContext);
            _abrirPlanos();
          },
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

  Future<void> _abrirPlanos() async {
    final pessoaAtualizada = await Navigator.push<PessoaModel>(
      context,
      MaterialPageRoute(builder: (_) => PlanScreen(pessoa: _pessoa)),
    );
    if (pessoaAtualizada != null && mounted) {
      setState(() => _pessoa = pessoaAtualizada);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recentes = _projetos.take(3).toList();
    final meusProjetos = _projetos
        .where((projeto) => projeto.nivelAcesso == 3)
        .toList();
    final projetosTerceiros = _projetos
        .where((projeto) => projeto.nivelAcesso != 3)
        .toList();
    final semProjetos = !_carregando && _projetos.isEmpty;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _carregarProjetos,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: HomeHeader(userName: _pessoa.nomePessoa),
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
                            color: _corProjeto(recentes[index]),
                            onTap: () => _abrirProjeto(recentes[index]),
                            onOptionsPressed: recentes[index].nivelAcesso >= 2
                                ? () => _abrirOpcoesProjeto(recentes[index])
                                : null,
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
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 210,
                          mainAxisExtent: 130,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                        ),
                    delegate: SliverChildBuilderDelegate((_, index) {
                      if (index == meusProjetos.length) {
                        return AddProjectCard(onPressed: _abrirNovoProjeto);
                      }
                      final projeto = meusProjetos[index];
                      return ProjectCard(
                        name: projeto.nomeProjeto,
                        color: _corProjeto(projeto),
                        onTap: () => _abrirProjeto(projeto),
                        onOptionsPressed: projeto.nivelAcesso >= 2
                            ? () => _abrirOpcoesProjeto(projeto)
                            : null,
                      );
                    }, childCount: meusProjetos.length + 1),
                  ),
                ),
                if (projetosTerceiros.isNotEmpty) ...[
                  const SliverPadding(
                    padding: EdgeInsets.fromLTRB(20, 4, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: SectionTitle(title: 'Projetos de terceiros'),
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
                        final projeto = projetosTerceiros[index];
                        return ProjectCard(
                          name: projeto.nomeProjeto,
                          color: _corProjeto(projeto),
                          onTap: () => _abrirProjeto(projeto),
                          onOptionsPressed: projeto.nivelAcesso >= 2
                              ? () => _abrirOpcoesProjeto(projeto)
                              : null,
                        );
                      }, childCount: projetosTerceiros.length),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _corProjeto(ProjetoModel projeto) {
    return projeto.nivelAcesso == 3
        ? const Color(0xFFC5DD64)
        : const Color(0xFF829764);
  }
}
