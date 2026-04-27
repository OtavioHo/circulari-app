import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSubmit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        name: _nameController.text.trim(),
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
              nameController: _nameController,
              emailController: _emailController,
              passwordController: _passwordController,
              confirmPasswordController: _confirmPasswordController,
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
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onSubmit;

  const _Form({
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
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
                'Cadastro',
                style: context.circulariTheme.typography.heading3.copyWith(
                  fontWeight: FontWeight.w800,
                  color: CirculariColorsTokens.greyscale100,
                ),
              ),
              Text(
                'Crie sua conta e aproveite a melhor forma de organizar seus bens.',
                textAlign: TextAlign.center,
                style: context.circulariTheme.typography.body.medium.light
                    .copyWith(color: CirculariColorsTokens.greyscale600),
              ),
              const SizedBox(height: 32),
              CirculariAuthTextFormField(
                label: 'Nome Completo',
                controller: nameController,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.person_outline,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),
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
                  if (!valid) return 'Digite um email válido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CirculariAuthTextFormField(
                label: 'Senha',
                controller: passwordController,
                obscureText: true,
                isAuth: true,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.lock_outline,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Obrigatório';
                  if (v.length < 8) return 'Pelo menos 8 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CirculariAuthTextFormField(
                label: 'Confirmar senha',
                controller: confirmPasswordController,
                obscureText: true,
                isAuth: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => onSubmit(),
                prefixIcon: Icons.lock_outline,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Obrigatório';
                  if (v != passwordController.text) return 'As senhas não coincidem';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              CirculariButton(onPressed: onSubmit, label: 'Cadastrar'),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.pop(),
                child: RichText(
                  text: TextSpan(
                    text: 'Já tem uma conta? ',
                    style: TextStyle(color: CirculariColorsTokens.greyscale600),
                    children: [
                      TextSpan(
                        text: ' Login',
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
