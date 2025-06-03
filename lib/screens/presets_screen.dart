import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dice_set.dart';
import '../providers/preset_provider.dart';
import '../providers/dice_set_provider.dart';

class PresetsScreen extends StatefulWidget {
  const PresetsScreen({super.key});

  @override
  State<PresetsScreen> createState() => _PresetsScreenState();
}

class _PresetsScreenState extends State<PresetsScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose () {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column (
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          // Presets list
          Expanded(
            child: Consumer<PresetProvider>(
              builder: (context, presetProvider, child) {
                final presets = presetProvider.presets;

                if (presets.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark_border,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No saved presets yet',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Save your favorite dice combinations for quick access',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: presets.length,
                  itemBuilder: (context, index) {
                    final preset = presets[index];
                    return Dismissible(
                      key: ValueKey(preset.id),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Preset'),
                            content: Text('Are you sure you want to delete "${preset.name}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('CANCEL'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text('DELETE'),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) {
                        presetProvider.deletePreset(preset.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${preset.name} deleted')),
                        );
                      },
                      child: Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            preset.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(_getDiceDescription(preset.diceSet)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Edit button
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showEditDialog(context, preset),
                              ),

                              // Load button
                              ElevatedButton(
                                onPressed: () {
                                  // Load this preset into the dice roller
                                  Provider.of<DiceSetProvider>(context, listen: false).loadDiceSet(preset.diceSet);
                                  
                                  // Find the page controller and navigate to the dice roller page
                                  /** mainScreen = context.findAncestorStateOfType<MainScreenState>();
                                  if (mainScreen != null) {
                                    mainScreen.pageController.animateToPage(
                                      1,
                                    duration: const Duration(milliseconds:300),
                                    curve: Curves.easeInOut,
                                    );
                                  } **/
                                },
                                child: const Text('LOAD'),
                              ),
                            ],
                          ),
                          onTap: () {
                            // Load this preset into the dice roller
                            Provider.of<DiceSetProvider>(context, listen: false).loadDiceSet(preset.diceSet);
                            // Find the page controller and navigate to the dice roller page
                                  /** final mainScreenState = context.findAncestorStateOfType<_MainScreenState>();
                                  if (mainScreenState != null) {
                                    mainScreenState._pageController.animateToPage(
                                      1,
                                    duration: const Duration(milliseconds:300),
                                    curve: Curves.easeInOut,
                                  );
                                  } **/
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Save current button
          Consumer<DiceSetProvider>(
            builder: (context, diceSetProvider, child) {
              final currentDiceSet = diceSetProvider.currentDiceSet;
              bool hasDice = currentDiceSet.dice.values.any((count) => count > 0);

              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton.icon(
                  onPressed: hasDice ? () => _showSaveDialog(context, currentDiceSet) : null,
                  icon: const Icon(Icons.save),
                  label: const Text('SAVE CURRENT DICE SET'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
              );
            },
          ),
        ],
          ),
        ),
      );
  }

  String _getDiceDescription(DiceSet diceSet) {
    final buffer = StringBuffer();
    diceSet.dice.forEach((sides, count) {
      if (count > 0) {
        buffer.write('$count d$sides, ');
      }
    });

    if (buffer.isEmpty) {
      return 'No dice selected';
    }

    String description = buffer.toString();
    description = description.substring(0, description.length - 2);

    if (diceSet.modifier != 0) {
      description += ' ${diceSet.modifier > 0 ? "+" : ""}${diceSet.modifier}';
    }

    return description;
  }

  void _showSaveDialog(BuildContext context, DiceSet diceSet) {
    _nameController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Preset'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Preset Name',
              hintText: 'Enter a name for this preset',
            ),

            autofocus: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final name = _nameController.text.trim();

                // Create a copy of the dice set to prevent reference issues
                final newDiceSet = DiceSet.fromMap(diceSet.toMap());

                Provider.of<PresetProvider>(context, listen: false).addPreset(name, newDiceSet);

                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Preset "$name" saved')),
                );
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, DiceSetPreset preset) {
    _nameController.text = preset.name;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Preset Name'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Preset Name',
            ),
            autofocus: true,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final name = _nameController.text.trim();

                Provider.of<PresetProvider>(context, listen: false).updatePresetName(preset.id, name);

                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Preset renamed to "$name"')),
                );
              }
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
}