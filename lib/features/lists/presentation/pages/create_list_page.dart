import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:circulari/features/lists/domain/entities/item_list.dart';
import 'package:circulari/features/lists/presentation/cubit/create_list_cubit.dart';
import 'package:circulari/features/lists/presentation/cubit/create_list_state.dart';
import 'package:circulari/features/lists/presentation/widgets/color_picker_section.dart';
import 'package:circulari/features/lists/presentation/widgets/icon_picker_section.dart';
import 'package:circulari/features/lists/presentation/widgets/picture_picker_section.dart';

/// List form page. With [initial] set it runs in edit mode: same fields,
/// "Editar lista" title, a delete action in the app bar, and PATCH on submit.
class CreateListPage extends StatelessWidget {
  final ItemList? initial;

  const CreateListPage({super.key, this.initial});

  @override
  Widget build(BuildContext context) {
    final editing = initial != null;
    return BlocListener<CreateListCubit, CreateListState>(
      listener: (context, state) {
        if (state is CreateListSuccess) {
          if (editing) {
            // The detail page reads name/color from the router extra, so the
            // stack is rebuilt with the updated entity (same approach as
            // add_item_form_page).
            context.go('/lists');
            context.push('/lists/${state.list.id}/items', extra: state.list);
          } else {
            context.pushReplacement(
              '/lists/${state.list.id}/items',
              extra: state.list,
            );
          }
        } else if (state is CreateListDeleted) {
          context.go('/lists');
        } else if (state is CreateListQuotaExceeded) {
          PaywallBottomSheet.show(
            context,
            onUpgrade: () => context.push('/paywall'),
          );
        }
      },
      child: _CreateListScaffold(initial: initial),
    );
  }
}

class _CreateListScaffold extends StatefulWidget {
  final ItemList? initial;

  const _CreateListScaffold({this.initial});

  @override
  State<_CreateListScaffold> createState() => _CreateListScaffoldState();
}

class _CreateListScaffoldState extends State<_CreateListScaffold> {
  late final _nameController =
      TextEditingController(text: widget.initial?.name);
  late final _locationController =
      TextEditingController(text: widget.initial?.location);
  final _formKey = GlobalKey<FormState>();

  bool get _editing => widget.initial != null;

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

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await ConfirmDeleteBottomSheet.show(
      context,
      title: 'Tem certeza que deseja excluir a lista?',
      message: 'Ao confirmar, ela será excluída de forma permanente, '
          'não sendo possível recuperá-la.',
      cancelLabel: 'Voltar para a lista',
      confirmLabel: 'Excluir lista',
    );
    if (confirmed == true && context.mounted) {
      context.read<CreateListCubit>().delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CirculariInAppScaffold(
      title: _editing ? 'Editar lista' : 'Criar Lista',
      actions: [
        if (_editing)
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: BlocBuilder<CreateListCubit, CreateListState>(
              builder: (context, state) => CirculariAppBarIconButton(
                icon: Icons.delete_outline,
                onPressed: state is CreateListReady && !state.submitting
                    ? () => _confirmDelete(context)
                    : null,
              ),
            ),
          ),
      ],
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
          CreateListDeleted() => const SizedBox.shrink(),
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
                    label: _editing ? 'Salvar lista' : 'Criar Lista',
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
