import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_event.dart';
import '../bloc/plan_bloc.dart';
import '../bloc/plan_event.dart';
import '../bloc/plan_state.dart';
import '../widgets/plan_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Widget _logoutButton(BuildContext context) {
    final typography = context.circulariTheme.typography;
    return TextButton(
      onPressed: () =>
          context.read<AuthBloc>().add(const AuthLogoutRequested()),
      child: Text(
        'Sair',
        style: typography.body.medium.regular.copyWith(
          color: const Color(0xFFD32F2F),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final typography = context.circulariTheme.typography;
    final spacing = context.circulariTheme.spacing;

    return Scaffold(
      backgroundColor: CirculariColorsTokens.greyscale100,
      appBar: AppBar(
        title: Text('Perfil', style: typography.heading6),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<PlanBloc, PlanState>(
        builder: (context, state) => switch (state) {
          PlanInitial() || PlanLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          PlanFailure(:final message) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.read<PlanBloc>().add(
                    const PlanLoadRequested(),
                  ),
                  child: const Text('Tentar novamente'),
                ),
                const SizedBox(height: 12),
                _logoutButton(context),
              ],
            ),
          ),
          PlanSuccess(:final plan) => ListView(
            padding: EdgeInsets.symmetric(vertical: spacing.medium),
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.medium,
                  vertical: spacing.small,
                ),
                child: Text(
                  'Seu plano',
                  style: typography.body.xLarge.bold.copyWith(
                    color: CirculariColorsTokens.greyscale800,
                  ),
                ),
              ),
              PlanCard(plan: plan),
              SizedBox(height: spacing.large),
              _logoutButton(context),
              SizedBox(height: spacing.medium),
            ],
          ),
        },
      ),
    );
  }
}
