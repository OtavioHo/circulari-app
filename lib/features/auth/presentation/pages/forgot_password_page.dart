import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/recovery_bloc.dart';
import '../bloc/recovery_event.dart';
import '../bloc/recovery_state.dart';
import 'recovery_route_args.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String? _submittedEmail;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    _submittedEmail = _emailController.text.trim();
    context.read<RecoveryBloc>().add(
      RecoveryForgotPasswordRequested(email: _submittedEmail!),
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
          if (state is RecoveryEmailSent) {
            context.push(
              '/auth/verify-otp',
              extra: VerifyOtpArgs(email: _submittedEmail!),
            );
          }
        },
        child: BlocBuilder<RecoveryBloc, RecoveryState>(
          builder: (context, state) => switch (state) {
            RecoveryInitial() ||
            RecoveryFailure() ||
            RecoveryEmailSent() =>
              _Form(
                formKey: _formKey,
                emailController: _emailController,
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
  final TextEditingController emailController;
  final VoidCallback onSubmit;

  const _Form({
    required this.formKey,
    required this.emailController,
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
              'Recuperar senha',
              style: context.circulariTheme.typography.heading3.copyWith(
                fontWeight: FontWeight.w800,
                color: CirculariColorsTokens.greyscale100,
              ),
            ),
            Text(
              'Informe seu e-mail e enviaremos um código para você redefinir sua senha.',
              textAlign: TextAlign.center,
              style: context.circulariTheme.typography.body.medium.light
                  .copyWith(color: CirculariColorsTokens.greyscale600),
            ),
            const SizedBox(height: 32),
            CirculariAuthTextFormField(
              label: 'Email',
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              prefixIcon: Icons.email_outlined,
              onFieldSubmitted: (_) => onSubmit(),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Obrigatório';
                final valid = RegExp(
                  r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
                ).hasMatch(v.trim());
                if (!valid) return 'E-mail inválido';
                return null;
              },
            ),
            const SizedBox(height: 24),
            CirculariButton(onPressed: onSubmit, label: 'Enviar código'),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'Voltar ao login',
                style: TextStyle(color: CirculariColorsTokens.greyscale600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
