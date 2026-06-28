import 'package:flutter/material.dart';

import '../../models/pessoa_model.dart';
import '../../services/pessoa_service.dart';
import 'payment_screen.dart';
import 'widgets/plan_card.dart';
import 'widgets/processing_payment_dialog.dart';

enum BillingPeriod { monthly, yearly }

class PlanScreen extends StatefulWidget {
  final PessoaModel pessoa;

  const PlanScreen({super.key, required this.pessoa});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  final _service = PessoaService();
  BillingPeriod _period = BillingPeriod.monthly;
  late PessoaModel _pessoa = widget.pessoa;
  bool _busy = false;

  String get _price =>
      _period == BillingPeriod.monthly ? 'R\$ 5,99' : 'R\$ 59,99';

  String get _periodLabel =>
      _period == BillingPeriod.monthly ? 'mensal' : 'anual';

  Future<void> _subscribe() async {
    final paid = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(period: _periodLabel, price: _price),
      ),
    );
    if (paid != true || !mounted) return;

    setState(() => _busy = true);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ProcessingPaymentDialog(),
    );

    await Future<void>.delayed(const Duration(seconds: 10));
    try {
      final idPessoa = _pessoa.idPessoa;
      if (idPessoa == null) throw Exception('Usuário sem identificação.');
      await _service.tornarPremium(idPessoa);
      if (!mounted) return;
      Navigator.pop(context);
      setState(() => _pessoa = _pessoa.copyWith(premium: true));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plano Premium ativado com sucesso.')),
      );
    } catch (error) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _requestCancellation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: const Text('Cancelar assinatura?'),
        content: const Text(
          'Você perderá o acesso aos benefícios Premium. '
          'Se possuir mais de um projeto, eles continuarão visíveis, '
          'mas novos projetos ficarão bloqueados.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Manter Premium'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar cancelamento'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      final idPessoa = _pessoa.idPessoa;
      if (idPessoa == null) throw Exception('Usuário sem identificação.');
      await _service.cancelarPremium(idPessoa);
      if (!mounted) return;
      setState(() => _pessoa = _pessoa.copyWith(premium: false));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assinatura Premium cancelada.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _close() {
    Navigator.pop(context, _pessoa);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !_busy) _close();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gerenciar plano'),
          leading: IconButton(
            onPressed: _busy ? null : _close,
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Text(
              'Escolha o plano ideal para você',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            SegmentedButton<BillingPeriod>(
              segments: const [
                ButtonSegment(
                  value: BillingPeriod.monthly,
                  label: Text('Mensal'),
                ),
                ButtonSegment(
                  value: BillingPeriod.yearly,
                  label: Text('Anual'),
                ),
              ],
              selected: {_period},
              onSelectionChanged: _busy
                  ? null
                  : (value) => setState(() => _period = value.first),
            ),
            const SizedBox(height: 22),
            PlanCard(
              title: 'Default',
              subtitle: 'Para começar a organizar',
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              current: !_pessoa.premium,
              benefits: const ['Funções básicas', 'Controle de 1 projeto'],
            ),
            const SizedBox(height: 16),
            PlanCard(
              title: 'Premium',
              subtitle: _period == BillingPeriod.monthly
                  ? 'Cobrança mensal'
                  : 'Cobrança anual',
              color: const Color(0xFFDDEDA7),
              current: _pessoa.premium,
              benefits: const [
                'Funções básicas',
                'Criação de projetos ilimitados',
                'Acesso a funcionalidades beta',
                'Serviço de suporte premium',
              ],
              action: _pessoa.premium
                  ? OutlinedButton(
                      onPressed: _busy ? null : _requestCancellation,
                      child: const Text('Cancelar assinatura'),
                    )
                  : FilledButton(
                      onPressed: _busy ? null : _subscribe,
                      child: Text('Assinar por $_price'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
