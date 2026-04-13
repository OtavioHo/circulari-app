import 'package:flutter/material.dart';

/// Used for both creating and renaming a list.
/// Returns the entered name, or null if cancelled.
Future<String?> showListNameDialog(
  BuildContext context, {
  String title = 'New list',
  String initialValue = '',
}) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => _ListNameDialog(title: title, initialValue: initialValue),
  );
}

class _ListNameDialog extends StatefulWidget {
  final String title;
  final String initialValue;

  const _ListNameDialog({required this.title, required this.initialValue});

  @override
  State<_ListNameDialog> createState() => _ListNameDialogState();
}

class _ListNameDialogState extends State<_ListNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final trimmed = _controller.text.trim();
    if (trimmed.isNotEmpty) Navigator.of(context).pop(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(hintText: 'List name'),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _submit,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
