import 'package:flutter/material.dart';

class FamilyCodeDialog extends StatefulWidget {
  const FamilyCodeDialog({super.key});

  @override
  State<FamilyCodeDialog> createState() => _FamilyCodeDialogState();
}

class _FamilyCodeDialogState extends State<FamilyCodeDialog> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Join Family'),
      content: TextField(
        controller: _codeController,
        decoration: const InputDecoration(
          labelText: 'Family code',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.group),
          hintText: 'e.g. FAM123',
        ),
        textCapitalization: TextCapitalization.characters,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _codeController.text.trim().toUpperCase()),
          child: const Text('Join'),
        ),
      ],
    );
  }
}
