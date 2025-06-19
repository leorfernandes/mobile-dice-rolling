import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/dice_set.dart';
import '../providers/preset_provider.dart';
import '../providers/dice_set_provider.dart';

/// Screen for managing dice presets.
/// 
/// Allows users to view, create, edit, delete, and load saved dice combinations.
class PresetsScreen extends StatefulWidget {
  final Function? onNavigateToRoller;

  const PresetsScreen({
    super.key,
    this.onNavigateToRoller,
  });

  @override
  State<PresetsScreen> createState() => _PresetsScreenState();
}

class _PresetsScreenState extends State<PresetsScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Presets list
                Expanded(
                  child: _buildPresetsList(),
                ),
              ],
            ),
          ),
        ),
        // Save button
        _buildSaveButton(),
      ]
    );
  }

  /// Builds the floating save button
  Widget _buildSaveButton() {
    return Positioned(
      bottom: 32,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () => _savePreset(context),
        child: Container(
          width: 128,
          height: 64,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(Icons.save, color: Theme.of(context).colorScheme.secondary),
          )
        )
      )
    );
  }

  /// Builds the list of presets or a placeholder if empty
  Widget _buildPresetsList() {
    return Consumer<PresetProvider>(
      builder: (context, presetProvider, child) {
        final presets = presetProvider.presets;

        if (presets.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          itemCount: presets.length,
          itemBuilder: (context, index) => _buildPresetItem(presets[index], presetProvider),
        );
      },
    );
  }

  /// Builds the empty state widget when no presets exist
  Widget _buildEmptyState() {
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

  /// Builds a single preset item with swipe-to-delete functionality
  Widget _buildPresetItem(DiceSetPreset preset, PresetProvider presetProvider) {
    return Dismissible(
      key: ValueKey(preset.id),
      background: Container(
        color: Theme.of(context).colorScheme.primary,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => _confirmDeletion(preset),
      onDismissed: (direction) => _handleDismissal(preset, presetProvider),
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
                tooltip: 'Edit preset name',
              ),

              // Load button
              ElevatedButton(
                onPressed: () => _loadPreset(preset.diceSet),
                child: const Text('LOAD'),
              ),
            ],
          ),
          onTap: () => _loadPreset(preset.diceSet),
        ),
      ),
    );
  }

  /// Confirms before deleting a preset
  Future<bool?> _confirmDeletion(DiceSetPreset preset) async {
    return showDialog<bool>(
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
  }

  /// Handles the dismissal of a preset item
  void _handleDismissal(DiceSetPreset preset, PresetProvider presetProvider) {
    try {
      presetProvider.deletePreset(preset.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${preset.name} deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting preset: ${e.toString()}')),
      );
    }
  }

  /// Loads a preset into the dice roller and navigates there
  void _loadPreset(DiceSet diceSet) {
    try {
      Provider.of<DiceSetProvider>(context, listen: false).loadDiceSet(diceSet);
      
      // Navigate to roller page if callback is provided
      if (widget.onNavigateToRoller != null) {
        widget.onNavigateToRoller!();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading preset: ${e.toString()}')),
      );
    }
  }

  /// Saves the current dice set as a new preset
  void _savePreset(BuildContext context) async {
    final diceSet = Provider.of<DiceSetProvider>(context, listen: false).currentDiceSet;
    
    // Check if there are any dice to save
    if (diceSet.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot save an empty dice set')),
      );
      return;
    }
    
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Preset'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Preset Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Icon(Icons.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Icon(Icons.save),
          ),
        ],
      ),
    );

    if (name != null && name.isNotEmpty) {
      try {
        Provider.of<PresetProvider>(context, listen: false).addPreset(name, diceSet);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Icon(Icons.check)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving preset: ${e.toString()}')),
        );
      }
    }
  }

  /// Converts a DiceSet to a human-readable string description
  String _getDiceDescription(DiceSet diceSet) {
    if (diceSet.isEmpty) {
      return 'No dice selected';
    }
    
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

  /// Shows a dialog to edit the name of a preset
  void _showEditDialog(BuildContext context, DiceSetPreset preset) {
    _nameController.text = preset.name;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _nameController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Preset Name'),
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
            onPressed: () => _updatePresetName(preset),
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }
  
  /// Updates the name of a preset if validation passes
  void _updatePresetName(DiceSetPreset preset) {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      
      try {
        Provider.of<PresetProvider>(context, listen: false).updatePresetName(preset.id, name);
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Preset renamed to "$name"')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating preset name: ${e.toString()}')),
        );
      }
    }
  }
}