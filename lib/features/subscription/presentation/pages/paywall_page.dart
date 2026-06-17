import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:circulari/core/models/plan_tier.dart';
import 'package:circulari/features/subscription/domain/entities/subscription_option.dart';
import 'package:circulari/features/subscription/presentation/bloc/paywall_bloc.dart';
import 'package:circulari/features/subscription/presentation/bloc/paywall_event.dart';
import 'package:circulari/features/subscription/presentation/bloc/paywall_state.dart';

class PaywallPage extends StatelessWidget {
  const PaywallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return CirculariInAppScaffold(
      title: 'Planos',
      body: BlocConsumer<PaywallBloc, PaywallState>(
        listenWhen: (prev, curr) => curr is PaywallReady,
        listener: (context, state) {
          if (state is! PaywallReady) return;
          if (state.purchasedTier != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Plano ${state.purchasedTier!.displayName} ativado!')),
            );
            // Signal the caller (e.g. Profile) to refresh, then close.
            context.pop(true);
          } else if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },
        builder: (context, state) => switch (state) {
          PaywallInitial() || PaywallLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
          PaywallFailure(:final message) => _ErrorView(message: message),
          PaywallReady(:final options, :final busy) => _OptionsView(options: options, busy: busy),
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          CirculariButton(
            label: 'Tentar novamente',
            onPressed: () => context.read<PaywallBloc>().add(const PaywallLoadRequested()),
          ),
        ],
      ),
    );
  }
}

class _OptionsView extends StatelessWidget {
  final List<SubscriptionOption> options;
  final bool busy;
  const _OptionsView({required this.options, required this.busy});

  @override
  Widget build(BuildContext context) {
    final spacing = context.circulariTheme.spacing;
    final typography = context.circulariTheme.typography;

    return ListView(
      padding: EdgeInsets.all(spacing.medium),
      children: [
        Text(
          'Faça mais com a Circulari',
          style: typography.body.xLarge.bold.copyWith(
            color: CirculariColorsTokens.greyscale900,
          ),
        ),
        SizedBox(height: spacing.small),
        Text(
          'Mais listas, mais itens e IA ilimitada.',
          style: typography.body.medium.regular.copyWith(
            color: CirculariColorsTokens.greyscale600,
          ),
        ),
        SizedBox(height: spacing.large),
        for (final option in options) ...[
          _PlanOptionCard(option: option, busy: busy),
          SizedBox(height: spacing.medium),
        ],
        SizedBox(height: spacing.small),
        Center(
          child: TextButton(
            onPressed:
                busy ? null : () => context.read<PaywallBloc>().add(const PaywallRestoreRequested()),
            child: const Text('Restaurar compras'),
          ),
        ),
      ],
    );
  }
}

class _PlanOptionCard extends StatelessWidget {
  final SubscriptionOption option;
  final bool busy;
  const _PlanOptionCard({required this.option, required this.busy});

  @override
  Widget build(BuildContext context) {
    final spacing = context.circulariTheme.spacing;
    final typography = context.circulariTheme.typography;
    final isPro = option.tier == PlanTier.pro;
    final accent = isPro ? CirculariColorsTokens.solarPulse500 : CirculariColorsTokens.freshCore600;

    return Container(
      padding: EdgeInsets.all(spacing.medium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isPro ? Icons.workspace_premium_rounded : Icons.star_rounded,
                  size: 20, color: accent),
              const SizedBox(width: 8),
              Text(
                option.tier.displayName,
                style: typography.body.large.bold.copyWith(color: accent),
              ),
              const Spacer(),
              Text(
                option.priceString,
                style: typography.body.large.bold.copyWith(
                  color: CirculariColorsTokens.greyscale900,
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.small),
          Text(
            option.title,
            style: typography.body.small.regular.copyWith(
              color: CirculariColorsTokens.greyscale600,
            ),
          ),
          SizedBox(height: spacing.medium),
          CirculariButton(
            label: 'Assinar ${option.tier.displayName}',
            isLoading: busy,
            onPressed: busy
                ? null
                : () => context.read<PaywallBloc>().add(PaywallPurchaseRequested(option.packageId)),
          ),
        ],
      ),
    );
  }
}
