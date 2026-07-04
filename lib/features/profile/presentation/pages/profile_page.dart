import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
      showBackButton: false,
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: spacing.medium),
        children: [
          const _ProfileHeader(),
          SizedBox(height: spacing.large),
          _ProfileOptionTile(
            icon: Icons.person_outline,
            label: 'Editar dados do perfil',
            onTap: () => context.push('/profile/edit'),
          ),
          SizedBox(height: spacing.medium),
          _ProfileOptionTile(
            icon: Icons.credit_card_outlined,
            label: 'Gerenciar plano',
            onTap: () => context.push('/paywall'),
          ),
          SizedBox(height: spacing.large),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.medium,
              vertical: spacing.small,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Seu plano',
                  style: typography.body.xLarge.bold.copyWith(
                    color: CirculariColorsTokens.greyscale800,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/paywall'),
                  child: Text(
                    'Gerenciar plano',
                    style: typography.body.large.regular.copyWith(
                      color: CirculariColorsTokens.greyscale500,
                      decoration: TextDecoration.underline,
                      decorationColor: CirculariColorsTokens.greyscale500,
                    ),
                  ),
                ),
              ],
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
              PlanSuccess(:final plan) => PlanCard(
                plan: plan,
                onUpgrade: () async {
                  final planBloc = context.read<PlanBloc>();
                  final purchased = await context.push<bool>('/paywall');
                  // Paywall already reconciled the backend; refresh usage here.
                  if (purchased == true) {
                    planBloc.add(const PlanLoadRequested());
                  }
                },
              ),
            },
          ),
          SizedBox(height: spacing.large),
          const _LogoutButton(),
          const SizedBox(height: 120),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _Avatar(name: name),
          SizedBox(height: spacing.medium),
          Text(
            name.isEmpty ? '—' : name,
            textAlign: TextAlign.center,
            style: typography.body.xLarge.bold.copyWith(
              color: CirculariColorsTokens.greyscale900,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.mail_outline_rounded,
                size: 16,
                color: CirculariColorsTokens.greyscale500,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  email.isEmpty ? '—' : email,
                  style: typography.body.medium.regular.copyWith(
                    color: CirculariColorsTokens.greyscale500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileOptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final typography = context.circulariTheme.typography;
    final spacing = context.circulariTheme.spacing;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.medium),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(spacing.medium),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: CirculariColorsTokens.greyscale200,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    size: 22,
                    color: CirculariColorsTokens.greyscale600,
                  ),
                ),
                SizedBox(width: spacing.medium),
                Expanded(
                  child: Text(
                    label,
                    style: typography.body.large.regular.copyWith(
                      color: CirculariColorsTokens.greyscale600,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: CirculariColorsTokens.greyscale500,
                ),
              ],
            ),
          ),
        ),
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
      width: 80,
      height: 80,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: CirculariColorsTokens.freshCore700,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: typography.heading4.copyWith(
          color: CirculariColorsTokens.greyscale50,
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  static const _red = Color(0xFFD32F2F);

  @override
  Widget build(BuildContext context) {
    final typography = context.circulariTheme.typography;
    final spacing = context.circulariTheme.spacing;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.medium),
      child: OutlinedButton.icon(
        onPressed: () =>
            context.read<AuthBloc>().add(const AuthLogoutRequested()),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: const BorderSide(color: _red),
        ),
        icon: const Icon(Icons.logout_rounded, color: _red),
        label: Text(
          'Sair',
          style: typography.body.medium.semibold.copyWith(color: _red),
        ),
      ),
    );
  }
}
