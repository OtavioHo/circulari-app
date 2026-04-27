import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/recovery_bloc.dart';
import '../bloc/recovery_event.dart';
import '../bloc/recovery_state.dart';
import 'recovery_route_args.dart';

class VerifyOtpPage extends StatefulWidget {
  final VerifyOtpArgs args;
  const VerifyOtpPage({super.key, required this.args});

  @override
  State<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends State<VerifyOtpPage> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _onSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<RecoveryBloc>().add(
      RecoveryVerifyOtpRequested(
        email: widget.args.email,
        otp: _otpController.text.trim(),
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
          if (state is RecoveryOtpVerified) {
            context.push(
              '/auth/reset-password',
              extra: ResetPasswordArgs(
                email: widget.args.email,
                resetToken: state.resetToken,
              ),
            );
          }
        },
        child: BlocBuilder<RecoveryBloc, RecoveryState>(
          builder: (context, state) => switch (state) {
            RecoveryInitial() ||
            RecoveryFailure() ||
            RecoveryOtpVerified() =>
              _Form(
                formKey: _formKey,
                otpController: _otpController,
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
  final TextEditingController otpController;
  final VoidCallback onSubmit;

  const _Form({
    required this.formKey,
    required this.otpController,
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
              'Verificar código',
              style: context.circulariTheme.typography.heading3.copyWith(
                fontWeight: FontWeight.w800,
                color: CirculariColorsTokens.greyscale100,
              ),
            ),
            Text(
              'Insira o código de 6 dígitos enviado para o seu e-mail.',
              textAlign: TextAlign.center,
              style: context.circulariTheme.typography.body.medium.light
                  .copyWith(color: CirculariColorsTokens.greyscale600),
            ),
            const SizedBox(height: 32),
            CirculariAuthTextFormField(
              label: 'Código',
              controller: otpController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              prefixIcon: Icons.pin_outlined,
              onFieldSubmitted: (_) => onSubmit(),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: 6,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Obrigatório';
                if (!RegExp(r'^\d{6}$').hasMatch(v)) {
                  return 'Insira os 6 dígitos do código';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            CirculariButton(onPressed: onSubmit, label: 'Verificar'),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'Reenviar código',
                style: TextStyle(color: CirculariColorsTokens.greyscale600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
