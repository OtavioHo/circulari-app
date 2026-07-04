import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:circulari/core/auth/auth_state_notifier.dart';
import 'package:circulari/features/profile/presentation/bloc/edit_profile_cubit.dart';
import 'package:circulari/features/profile/presentation/bloc/edit_profile_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(
      text: context.read<AuthStateNotifier>().userName ?? '',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<EditProfileCubit>().submit(name: _nameCtrl.text);
  }

  void _onState(BuildContext context, EditProfileState state) {
    if (state is EditProfileSuccess) {
      context.read<AuthStateNotifier>().setUserName(state.name);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );
      context.pop();
    } else if (state is EditProfileFailure) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.circulariTheme;
    final email = context.read<AuthStateNotifier>().userEmail ?? '';

    return CirculariInAppScaffold(
      title: 'Editar perfil',
      body: BlocConsumer<EditProfileCubit, EditProfileState>(
        listener: _onState,
        builder: (context, state) {
          final isSubmitting = state is EditProfileSubmitting;
          return AbsorbPointer(
            absorbing: isSubmitting,
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    'Dados do perfil',
                    style: theme.typography.heading3.copyWith(
                      color: CirculariColorsTokens.greyscale900,
                    ),
                  ),
                  Text(
                    'Atualize as informações da sua conta.',
                    style: theme.typography.body.large.regular.copyWith(
                      color: CirculariColorsTokens.greyscale500,
                    ),
                  ),
                  SizedBox(height: theme.spacing.large),
                  CirculariTextFormField(
                    controller: _nameCtrl,
                    label: 'Nome',
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'O nome é obrigatório'
                        : null,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  if (email.isNotEmpty) ...[
                    SizedBox(height: theme.spacing.large),
                    Text(
                      'E-mail',
                      style: theme.typography.body.large.regular.copyWith(
                        color: CirculariColorsTokens.greyscale600,
                      ),
                    ),
                    SizedBox(height: theme.spacing.small),
                    Row(
                      children: [
                        const Icon(
                          Icons.mail_outline_rounded,
                          size: 18,
                          color: CirculariColorsTokens.greyscale500,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            email,
                            style: theme.typography.body.medium.regular.copyWith(
                              color: CirculariColorsTokens.greyscale500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: theme.spacing.xLarge),
                  CirculariButton(
                    label: 'Salvar alterações',
                    isLoading: isSubmitting,
                    onPressed: isSubmitting ? null : _submit,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
