import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/preset_provider.dart';

class PresetsScreen extends StatelessWidget {
  const PresetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presets'),
      ),
      body: Consumer<PresetProvider>(
        builder: (context, presetProvider, child) {
          final presets = presetProvider.presets;

          if (presets.isEmpty) {
            return const Center(
              child: Text('No presets saved yet'),
            );
          }

          return ListView.builder(
            itemCount: presets.length,
            itemBuilder: (context, index) {
              final preset = presets[index];
              return ListTile(
                title: Text(preset.name),
                subtitle: Text(
                  '${preset.diceSet}d${preset.diceSet}' // Needs to update for dice and sides
                  '${preset.diceSet.modifier != 0 ? ' + ${preset.diceSet.modifier}' : ''}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    presetProvider.deletePreset(preset.id);
                  },
                ),
                onTap: () {
                  Navigator.of(context).pop(preset);
                },
              );
            },
          );
        },
      ),
    );
  }
}