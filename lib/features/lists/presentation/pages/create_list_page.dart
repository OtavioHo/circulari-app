import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubit/create_list_cubit.dart';
import '../cubit/create_list_state.dart';
import '../widgets/color_picker_section.dart';
import '../widgets/icon_picker_section.dart';
import '../widgets/picture_picker_section.dart';

class CreateListPage extends StatelessWidget {
  const CreateListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateListCubit, CreateListState>(
      listener: (context, state) {
        if (state is CreateListSuccess) {
          context.pushReplacement(
            '/lists/${state.list.id}/items',
            extra: state.list,
          );
        } else if (state is CreateListQuotaExceeded) {
          PaywallBottomSheet.show(context, resourceName: 'listas');
        }
      },
      child: const _CreateListScaffold(),
    );
  }
}

class _CreateListScaffold extends StatefulWidget {
  const _CreateListScaffold();

  @override
  State<_CreateListScaffold> createState() => _CreateListScaffoldState();
}

class _CreateListScaffoldState extends State<_CreateListScaffold> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<CreateListCubit>().submit(
      name: _nameController.text.trim(),
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CirculariInAppScaffold(
      title: 'Criar Lista',
      body: BlocBuilder<CreateListCubit, CreateListState>(
        builder: (context, state) => switch (state) {
          CreateListInitial() || CreateListLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          CreateListOptionsFailure(:final message) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () =>
                      context.read<CreateListCubit>().loadOptions(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          CreateListSuccess() => const SizedBox.shrink(),
          CreateListQuotaExceeded() => const SizedBox.shrink(),
          CreateListReady(
            :final colors,
            :final icons,
            :final pictures,
            :final selectedColor,
            :final selectedIcon,
            :final selectedPicture,
            :final submitting,
            :final errorMessage,
          ) =>
            Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  CirculariTextFormField(
                    controller: _nameController,
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Name is required'
                        : null,
                    label: 'Nome',
                  ),
                  const SizedBox(height: 16),
                  CirculariTextFormField(
                    controller: _locationController,
                    label: 'Location (optional)',
                  ),
                  const SizedBox(height: 28),
                  ColorPickerSection(
                    colors: colors,
                    selected: selectedColor,
                    onSelect: submitting
                        ? (_) {}
                        : context.read<CreateListCubit>().selectColor,
                  ),
                  const SizedBox(height: 28),
                  IconPickerSection(
                    icons: icons,
                    selected: selectedIcon,
                    onSelect: submitting
                        ? (_) {}
                        : context.read<CreateListCubit>().selectIcon,
                  ),
                  const SizedBox(height: 28),
                  PicturePickerSection(
                    pictures: pictures,
                    selected: selectedPicture,
                    onSelect: submitting
                        ? (_) {}
                        : context.read<CreateListCubit>().selectPicture,
                  ),
                  const SizedBox(height: 28),
                  if (errorMessage != null) ...[
                    Text(
                      errorMessage,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                  ],
                  CirculariButton(
                    onPressed: submitting ? null : () => _submit(context),
                    isLoading: submitting,
                    label: 'Criar Lista',
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
        },
      ),
    );
  }
}
