import 'package:flutter/material.dart';

import '../components/user_header_card.dart';
import '../core/api_config.dart';
import '../core/app_colors.dart';
import '../models/item_lista_model.dart';
import '../models/lista_model.dart';
import '../models/pessoa_model.dart';
import '../models/projeto_model.dart';
import '../services/item_lista_service.dart';
import '../services/lista_service.dart';
import '../services/projeto_service.dart';
import 'home/widgets/itens_tab.dart';
import 'home/widgets/listas_tab.dart';
import 'home/widgets/projetos_tab.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  final PessoaModel pessoa;

  const HomePage({
    super.key,
    required this.pessoa,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _projetoService = ProjetoService();
  final _listaService = ListaService();
  final _itemService = ItemListaService();

  final _nomeProjetoController = TextEditingController();
  final _buscarProjetoController = TextEditingController();

  final _nomeListaController = TextEditingController();
  final _idProjetoDaListaController = TextEditingController();
  final _buscarListaController = TextEditingController();

  final _nomeItemController = TextEditingController();
  final _quantidadeItemController = TextEditingController(text: '1');
  final _idListaDoItemController = TextEditingController();
  final _buscarItemController = TextEditingController();

  final List<ProjetoModel> _projetos = [];
  final List<ListaModel> _listas = [];
  final List<ItemListaModel> _itens = [];

  bool _carregando = false;
  bool _listaFeitaAoCriar = false;
  bool _itemEhTarefa = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarDadosIniciais();
    });
  }

  @override
  void dispose() {
    _nomeProjetoController.dispose();
    _buscarProjetoController.dispose();
    _nomeListaController.dispose();
    _idProjetoDaListaController.dispose();
    _buscarListaController.dispose();
    _nomeItemController.dispose();
    _quantidadeItemController.dispose();
    _idListaDoItemController.dispose();
    _buscarItemController.dispose();
    super.dispose();
  }

  Future<void> _carregarDadosIniciais() async {
    await _executar(() async {
      final projetos = await _projetoService.listarTodos();
      final listas = await _listaService.listarTodos();
      final itens = await _itemService.listarTodos();

      setState(() {
        _projetos
          ..clear()
          ..addAll(projetos.reversed);
        _listas
          ..clear()
          ..addAll(listas.reversed);
        _itens
          ..clear()
          ..addAll(itens.reversed);
      });
    });
  }

  Future<void> _executar(Future<void> Function() acao) async {
    if (_carregando) return;

    setState(() => _carregando = true);

    try {
      await acao();
    } catch (error) {
      if (!mounted) return;
      _mostrarErro(error);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _criarProjeto() async {
    final nome = _nomeProjetoController.text.trim();
    if (nome.isEmpty) {
      _mostrarMensagem('Digite o nome do projeto.');
      return;
    }

    await _executar(() async {
      final projeto = await _projetoService.criarProjeto(
        ProjetoModel(nomeProjeto: nome),
      );

      setState(() {
        _adicionarOuAtualizarProjeto(projeto);
        _nomeProjetoController.clear();
      });

      _mostrarMensagem('Projeto criado com sucesso.');
    });
  }

  Future<void> _buscarProjeto() async {
    final id = _parseId(_buscarProjetoController.text);
    if (id == null) {
      _mostrarMensagem('Digite um ID de projeto válido.');
      return;
    }

    await _executar(() async {
      final projeto = await _projetoService.buscarProjetoPorId(id);

      if (projeto == null) {
        _mostrarMensagem('Projeto não encontrado.');
        return;
      }

      setState(() {
        _adicionarOuAtualizarProjeto(projeto);
        _buscarProjetoController.clear();
      });
    });
  }

  Future<void> _editarProjeto(ProjetoModel projeto) async {
    final novoNome = await _pedirTexto(
      titulo: 'Editar projeto',
      label: 'Nome do projeto',
      valorInicial: projeto.nomeProjeto,
    );

    if (novoNome == null || novoNome.trim().isEmpty) return;

    final atualizado = projeto.copyWith(nomeProjeto: novoNome.trim());

    await _executar(() async {
      await _projetoService.atualizarProjeto(atualizado);
      setState(() => _adicionarOuAtualizarProjeto(atualizado));
      _mostrarMensagem('Projeto atualizado.');
    });
  }

  Future<void> _deletarProjeto(ProjetoModel projeto) async {
    final id = projeto.idProjeto;
    if (id == null) return;

    final confirmar = await _confirmar(
      titulo: 'Deletar projeto?',
      mensagem: 'As listas vinculadas também podem ser removidas pelo banco.',
    );

    if (!confirmar) return;

    await _executar(() async {
      await _projetoService.deletarProjeto(id);
      setState(() {
        _projetos.removeWhere((p) => p.idProjeto == id);
        _listas.removeWhere((l) => l.idProjeto == id);
      });
      _mostrarMensagem('Projeto deletado.');
    });
  }

  Future<void> _criarLista() async {
    final nome = _nomeListaController.text.trim();
    final idProjeto = _parseId(_idProjetoDaListaController.text);

    if (nome.isEmpty) {
      _mostrarMensagem('Digite o nome da lista.');
      return;
    }
    if (idProjeto == null) {
      _mostrarMensagem('Digite o ID do projeto onde a lista ficará.');
      return;
    }

    await _executar(() async {
      final lista = await _listaService.criarLista(
        ListaModel(
          nomeLista: nome,
          idProjeto: idProjeto,
          feito: _listaFeitaAoCriar,
        ),
      );

      setState(() {
        _adicionarOuAtualizarLista(lista.copyWith(idProjeto: idProjeto));
        _nomeListaController.clear();
        _listaFeitaAoCriar = false;
      });

      _mostrarMensagem('Lista criada com sucesso.');
    });
  }

  Future<void> _buscarLista() async {
    final id = _parseId(_buscarListaController.text);
    if (id == null) {
      _mostrarMensagem('Digite um ID de lista válido.');
      return;
    }

    await _executar(() async {
      final lista = await _listaService.buscarListaPorId(id);

      if (lista == null) {
        _mostrarMensagem('Lista não encontrada.');
        return;
      }

      setState(() {
        _adicionarOuAtualizarLista(lista);
        _buscarListaController.clear();
      });
    });
  }

  Future<void> _editarLista(ListaModel lista) async {
    final novoNome = await _pedirTexto(
      titulo: 'Editar lista',
      label: 'Nome da lista',
      valorInicial: lista.nomeLista,
    );

    if (novoNome == null || novoNome.trim().isEmpty) return;

    final atualizado = lista.copyWith(nomeLista: novoNome.trim());

    await _executar(() async {
      await _listaService.atualizarLista(atualizado);
      setState(() => _adicionarOuAtualizarLista(atualizado));
      _mostrarMensagem('Lista atualizada.');
    });
  }

  Future<void> _alternarListaFeita(ListaModel lista, bool feito) async {
    final atualizado = lista.copyWith(feito: feito);

    await _executar(() async {
      await _listaService.atualizarLista(atualizado);
      setState(() => _adicionarOuAtualizarLista(atualizado));
    });
  }

  Future<void> _deletarLista(ListaModel lista) async {
    final id = lista.idLista;
    if (id == null) return;

    final confirmar = await _confirmar(
      titulo: 'Deletar lista?',
      mensagem: 'Os itens vinculados podem ser removidos pelo banco.',
    );

    if (!confirmar) return;

    await _executar(() async {
      await _listaService.deletarLista(id);
      setState(() {
        _listas.removeWhere((l) => l.idLista == id);
        _itens.removeWhere((i) => i.idLista == id);
      });
      _mostrarMensagem('Lista deletada.');
    });
  }

  Future<void> _criarItem() async {
    final nome = _nomeItemController.text.trim();
    final idLista = _parseId(_idListaDoItemController.text);
    final quantidade = _itemEhTarefa
        ? 1
        : (int.tryParse(_quantidadeItemController.text.trim()) ?? 0);

    if (nome.isEmpty) {
      _mostrarMensagem('Digite o nome do item.');
      return;
    }
    if (idLista == null) {
      _mostrarMensagem('Digite o ID da lista onde o item ficará.');
      return;
    }
    if (!_itemEhTarefa && quantidade < 1) {
      _mostrarMensagem('Quantidade precisa ser maior ou igual a 1.');
      return;
    }

    await _executar(() async {
      final item = await _itemService.criarItem(
        ItemListaModel(
          nomeItem: nome,
          idLista: idLista,
          quantidade: quantidade,
          isTarefa: _itemEhTarefa,
        ),
      );

      setState(() {
        _adicionarOuAtualizarItem(item.copyWith(idLista: idLista));
        _nomeItemController.clear();
        _quantidadeItemController.text = '1';
        _itemEhTarefa = true;
      });

      _mostrarMensagem('Item criado com sucesso.');
    });
  }

  Future<void> _buscarItem() async {
    final id = _parseId(_buscarItemController.text);
    if (id == null) {
      _mostrarMensagem('Digite um ID de item válido.');
      return;
    }

    await _executar(() async {
      final item = await _itemService.buscarItemPorId(id);

      if (item == null) {
        _mostrarMensagem('Item não encontrado.');
        return;
      }

      setState(() {
        _adicionarOuAtualizarItem(item);
        _buscarItemController.clear();
      });
    });
  }

  Future<void> _editarItem(ItemListaModel item) async {
    final novoNome = await _pedirTexto(
      titulo: 'Editar item',
      label: 'Nome do item',
      valorInicial: item.nomeItem,
    );

    if (novoNome == null || novoNome.trim().isEmpty) return;

    final atualizado = item.copyWith(nomeItem: novoNome.trim());

    await _executar(() async {
      await _itemService.atualizarItem(atualizado);
      setState(() => _adicionarOuAtualizarItem(atualizado));
      _mostrarMensagem('Item atualizado.');
    });
  }

  Future<void> _alternarItemConcluido(ItemListaModel item, bool concluido) async {
    final atualizado = item.copyWith(concluido: concluido);

    await _executar(() async {
      await _itemService.atualizarItem(atualizado);
      setState(() => _adicionarOuAtualizarItem(atualizado));
    });
  }

  Future<void> _deletarItem(ItemListaModel item) async {
    final id = item.idItem;
    if (id == null) return;

    final confirmar = await _confirmar(
      titulo: 'Deletar item?',
      mensagem: 'Essa ação remove o item da lista.',
    );

    if (!confirmar) return;

    await _executar(() async {
      await _itemService.deletarItem(id);
      setState(() => _itens.removeWhere((i) => i.idItem == id));
      _mostrarMensagem('Item deletado.');
    });
  }

  void _adicionarOuAtualizarProjeto(ProjetoModel projeto) {
    final index = _projetos.indexWhere((p) => p.idProjeto == projeto.idProjeto);
    if (index >= 0) {
      _projetos[index] = projeto;
    } else {
      _projetos.insert(0, projeto);
    }
  }

  void _adicionarOuAtualizarLista(ListaModel lista) {
    final index = _listas.indexWhere((l) => l.idLista == lista.idLista);
    if (index >= 0) {
      _listas[index] = lista;
    } else {
      _listas.insert(0, lista);
    }
  }

  void _adicionarOuAtualizarItem(ItemListaModel item) {
    final index = _itens.indexWhere((i) => i.idItem == item.idItem);
    if (index >= 0) {
      _itens[index] = item;
    } else {
      _itens.insert(0, item);
    }
  }

  int? _parseId(String value) {
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed < 1) return null;
    return parsed;
  }

  Future<String?> _pedirTexto({
    required String titulo,
    required String label,
    required String valorInicial,
  }) async {
    final controller = TextEditingController(text: valorInicial);

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titulo),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _confirmar({
    required String titulo,
    required String mensagem,
  }) async {
    final resposta = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(mensagem),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    return resposta ?? false;
  }

  void _mostrarMensagem(String mensagem) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  void _mostrarErro(Object error) {
    final mensagem = error.toString().replaceFirst('Exception: ', '');
    final texto = mensagem.contains('XMLHttpRequest') || mensagem.contains('SocketException')
        ? 'Não consegui acessar o backend. Verifique se ele está rodando e se a API está em ${ApiConfig.baseUrl}.'
        : mensagem;

    _mostrarMensagem(texto);
  }

  void _sair() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _alterarListaFeitaAoCriar(bool value) {
    setState(() => _listaFeitaAoCriar = value);
  }

  void _alterarTipoItem(bool value) {
    setState(() {
      _itemEhTarefa = value;
      if (value) _quantidadeItemController.text = '1';
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
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
              tooltip: 'Recarregar dados',
              onPressed: _carregarDadosIniciais,
              icon: const Icon(Icons.refresh_rounded),
            ),
            IconButton(
              tooltip: 'Sair',
              onPressed: _sair,
              icon: const Icon(Icons.logout_rounded),
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.folder_rounded), text: 'Projetos'),
              Tab(icon: Icon(Icons.list_alt_rounded), text: 'Listas'),
              Tab(icon: Icon(Icons.check_circle_rounded), text: 'Itens'),
            ],
          ),
        ),
        body: Column(
          children: [
            UserHeaderCard(
              nome: widget.pessoa.nomePessoa,
              email: widget.pessoa.email,
              idPessoa: widget.pessoa.idPessoa,
            ),
            if (_carregando) const LinearProgressIndicator(minHeight: 3),
            Expanded(
              child: TabBarView(
                children: [
                  ProjetosTab(
                    nomeProjetoController: _nomeProjetoController,
                    buscarProjetoController: _buscarProjetoController,
                    projetos: _projetos,
                    carregando: _carregando,
                    onCriarProjeto: _criarProjeto,
                    onBuscarProjeto: _buscarProjeto,
                    onEditarProjeto: _editarProjeto,
                    onDeletarProjeto: _deletarProjeto,
                  ),
                  ListasTab(
                    nomeListaController: _nomeListaController,
                    idProjetoDaListaController: _idProjetoDaListaController,
                    buscarListaController: _buscarListaController,
                    listas: _listas,
                    carregando: _carregando,
                    listaFeitaAoCriar: _listaFeitaAoCriar,
                    onCriarLista: _criarLista,
                    onBuscarLista: _buscarLista,
                    onListaFeitaAoCriarChanged: _alterarListaFeitaAoCriar,
                    onEditarLista: _editarLista,
                    onDeletarLista: _deletarLista,
                    onAlternarListaFeita: _alternarListaFeita,
                  ),
                  ItensTab(
                    nomeItemController: _nomeItemController,
                    quantidadeItemController: _quantidadeItemController,
                    idListaDoItemController: _idListaDoItemController,
                    buscarItemController: _buscarItemController,
                    itens: _itens,
                    carregando: _carregando,
                    itemEhTarefa: _itemEhTarefa,
                    onCriarItem: _criarItem,
                    onBuscarItem: _buscarItem,
                    onItemEhTarefaChanged: _alterarTipoItem,
                    onEditarItem: _editarItem,
                    onDeletarItem: _deletarItem,
                    onAlternarItemConcluido: _alternarItemConcluido,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
