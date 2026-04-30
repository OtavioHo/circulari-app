import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:circulari/core/auth/auth_state_notifier.dart';
import 'package:circulari/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:circulari/features/auth/presentation/bloc/auth_event.dart';
import 'package:circulari/features/profile/presentation/bloc/plan_bloc.dart';
import 'package:circulari/features/profile/presentation/bloc/plan_event.dart';
import 'package:circulari/features/profile/presentation/bloc/plan_state.dart';
import 'package:circulari/features/profile/presentation/widgets/plan_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final typography = context.circulariTheme.typography;
    final spacing = context.circulariTheme.spacing;

    return CirculariInAppScaffold(
      title: 'Perfil',
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: spacing.medium),
        children: [
          const _ProfileHeader(),
          SizedBox(height: spacing.large),
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
          BlocBuilder<PlanBloc, PlanState>(
            builder: (context, state) => switch (state) {
              PlanInitial() || PlanLoading() => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              PlanFailure(:final message) => Padding(
                padding: EdgeInsets.symmetric(horizontal: spacing.medium),
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
                  ],
                ),
              ),
              PlanSuccess(:final plan) => PlanCard(plan: plan),
            },
          ),
          SizedBox(height: spacing.large),
          const _LogoutButton(),
          SizedBox(height: spacing.medium),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final typography = context.circulariTheme.typography;
    final spacing = context.circulariTheme.spacing;
    final notifier = context.watch<AuthStateNotifier>();
    final name = notifier.userName ?? '';
    final email = notifier.userEmail ?? '';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: spacing.medium),
      padding: EdgeInsets.all(spacing.medium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _Avatar(name: name),
          SizedBox(width: spacing.medium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? '—' : name,
                  style: typography.body.xLarge.bold.copyWith(
                    color: CirculariColorsTokens.greyscale900,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.mail_outline_rounded,
                      size: 16,
                      color: CirculariColorsTokens.greyscale500,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        email.isEmpty ? '—' : email,
                        style: typography.body.small.regular.copyWith(
                          color: CirculariColorsTokens.greyscale600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String name;

  const _Avatar({required this.name});

  String get _initials {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts.first.characters.first.toUpperCase();
    }
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final typography = context.circulariTheme.typography;
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: CirculariColorsTokens.freshCore100,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: typography.heading4.copyWith(
          color: CirculariColorsTokens.freshCore600,
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    final typography = context.circulariTheme.typography;
    return TextButton.icon(
      onPressed: () =>
          context.read<AuthBloc>().add(const AuthLogoutRequested()),
      icon: const Icon(Icons.logout_rounded, color: Color(0xFFD32F2F)),
      label: Text(
        'Sair',
        style: typography.body.medium.bold.copyWith(
          color: const Color(0xFFD32F2F),
        ),
      ),
    );
  }
}
