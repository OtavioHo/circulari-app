import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      AuthLoginRequested(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CirculariAuthScaffold(
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) => switch (state) {
            AuthInitial() || AuthFailure() => _Form(
              formKey: _formKey,
              emailController: _emailController,
              passwordController: _passwordController,
              onSubmit: () => _onSubmit(context),
            ),
            AuthLoading() => const Center(child: CircularProgressIndicator()),
            AuthSuccess() => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }
}

class _Form extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;

  const _Form({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
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
                'Login',
                style: context.circulariTheme.typography.heading3.copyWith(
                  fontWeight: FontWeight.w800,
                  color: CirculariColorsTokens.greyscale100,
                ),
              ),
              Text(
                'Faça seu login e aproveite a melhor forma de organizar seus bens. ',
                textAlign: TextAlign.center,
                style: context.circulariTheme.typography.body.medium.light
                    .copyWith(color: CirculariColorsTokens.greyscale600),
              ),
              const SizedBox(height: 32),
              CirculariAuthTextFormField(
                label: 'Email',
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.email_outlined,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final email = v.trim();
                  final valid = RegExp(
                    r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
                  ).hasMatch(email);
                  if (!valid) return 'Enter a valid email';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CirculariAuthTextFormField(
                label: 'Senha',
                controller: passwordController,
                isAuth: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => onSubmit(),
                prefixIcon: Icons.lock_outline,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (v.length < 8) return 'At least 8 characters';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/auth/forgot-password'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Esqueci minha senha',
                    style: context.circulariTheme.typography.body.medium.light
                        .copyWith(color: CirculariColorsTokens.greyscale600),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CirculariButton(onPressed: onSubmit, label: 'Login'),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.push('/auth/register'),
                child: RichText(
                  text: TextSpan(
                    text: "Ainda não tem uma conta? ",
                    style: TextStyle(color: CirculariColorsTokens.greyscale600),
                    children: [
                      TextSpan(
                        text: 'Crie uma conta',
                        style: TextStyle(
                          color: CirculariColorsTokens.greyscale100,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
