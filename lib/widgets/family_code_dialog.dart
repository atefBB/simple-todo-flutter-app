import 'package:flutter/material.dart';
import '../generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.joinFamilyDialog),
      content: TextField(
        controller: _codeController,
        decoration: InputDecoration(
          labelText: l10n.familyCode,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.group),
          hintText: l10n.familyCodeHint,
        ),
        textCapitalization: TextCapitalization.characters,
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () =>
              Navigator.pop(context, _codeController.text.trim().toUpperCase()),
          child: Text(l10n.join),
        ),
      ],
    );
  }
}
