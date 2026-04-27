import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/recovery_bloc.dart';
import '../bloc/recovery_event.dart';
import '../bloc/recovery_state.dart';
import 'recovery_route_args.dart';

class ResetPasswordPage extends StatefulWidget {
  final ResetPasswordArgs args;
  const ResetPasswordPage({super.key, required this.args});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _onSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<RecoveryBloc>().add(
      RecoveryResetPasswordRequested(
        email: widget.args.email,
        resetToken: widget.args.resetToken,
        newPassword: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CirculariAuthScaffold(
      child: BlocListener<RecoveryBloc, RecoveryState>(
        listener: (context, state) {
          if (state is RecoveryFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is RecoveryPasswordReset) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Senha redefinida com sucesso!'),
              ),
            );
            context.go('/auth/login');
          }
        },
        child: BlocBuilder<RecoveryBloc, RecoveryState>(
          builder: (context, state) => switch (state) {
            RecoveryInitial() ||
            RecoveryFailure() ||
            RecoveryPasswordReset() =>
              _Form(
                formKey: _formKey,
                passwordController: _passwordController,
                confirmController: _confirmController,
                onSubmit: () => _onSubmit(context),
              ),
            RecoveryLoading() =>
              const Center(child: CircularProgressIndicator()),
            _ => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }
}

class _Form extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final VoidCallback onSubmit;

  const _Form({
    required this.formKey,
    required this.passwordController,
    required this.confirmController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Text(
              'Nova senha',
              style: context.circulariTheme.typography.heading3.copyWith(
                fontWeight: FontWeight.w800,
                color: CirculariColorsTokens.greyscale100,
              ),
            ),
            Text(
              'Crie uma nova senha para sua conta.',
              textAlign: TextAlign.center,
              style: context.circulariTheme.typography.body.medium.light
                  .copyWith(color: CirculariColorsTokens.greyscale600),
            ),
            const SizedBox(height: 32),
            CirculariAuthTextFormField(
              label: 'Nova senha',
              controller: passwordController,
              isAuth: true,
              textInputAction: TextInputAction.next,
              prefixIcon: Icons.lock_outline,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Obrigatório';
                if (v.length < 8) return 'Pelo menos 8 caracteres';
                if (!RegExp(r'[A-Z]').hasMatch(v)) {
                  return 'Deve conter letra maiúscula';
                }
                if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(v)) {
                  return 'Deve conter caractere especial';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CirculariAuthTextFormField(
              label: 'Confirmar senha',
              controller: confirmController,
              isAuth: true,
              textInputAction: TextInputAction.done,
              prefixIcon: Icons.lock_outline,
              onFieldSubmitted: (_) => onSubmit(),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Obrigatório';
                if (v != passwordController.text) {
                  return 'As senhas não coincidem';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            CirculariButton(onPressed: onSubmit, label: 'Redefinir senha'),
          ],
        ),
      ),
    );
  }
}
