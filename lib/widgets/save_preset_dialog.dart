import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/preset_provider.dart';

class SavePresetDialog extends StatefulWidget {
  final int sides;
  final int count;
  final int modifier;

  const SavePresetDialog({
    super.key,
    required this.sides,
    required this.count,
    required this.modifier,
  });

  @override
  State<SavePresetDialog> createState() => _SavePresetDialogState();
}

class _SavePresetDialogState extends State<SavePresetDialog> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Save Preset'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Save ${widget.count}d${widget.sides}' + 
            (widget.modifier != 0
              ? ' + $widget.modifier'
              : ''),
              style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Preset Name',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              final presetProvider = Provider.of<PresetProvider>(
                context,
                listen: false,
              );

              presetProvider.addPreset(
                _nameController.text,
                widget.sides,
                widget.count,
                widget.modifier,
              );

              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Preset "${_nameController.text}" saved')),
              );
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}