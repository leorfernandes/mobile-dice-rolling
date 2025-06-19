import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/roll_entry.dart';

/// A screen that displays detailed information about a dice roll.
class RollDetailScreen extends StatelessWidget {
  final RollEntry rollEntry;

  const RollDetailScreen({
    super.key,
    required this.rollEntry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roll Details'),
        centerTitle: true,
      ),
      body: _buildBody(context),
    );
  }

  /// Builds the main body of the screen with proper constraints and scrolling.
  Widget _buildBody(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildRollResults(context),
              if (rollEntry.modifier != 0) _buildModifier(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the header with total roll value and timestamp.
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        _buildDiceBox(
          context,
          size: 52,
          value: rollEntry.total.toString(),
          fontSize: 22,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rollEntry.diceDescription,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                _formatTimestamp(rollEntry.timestamp),
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Formats the timestamp in a readable format.
  String _formatTimestamp(DateTime timestamp) {
    try {
      return DateFormat('MMM d, yyyy - h:mm a').format(timestamp);
    } catch (e) {
      // Fallback in case of formatting error
      return timestamp.toString();
    }
  }

  /// Builds the section showing detailed roll results for each die type.
  Widget _buildRollResults(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Roll Results',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(),
        if (rollEntry.diceResults.isEmpty)
          const Text('No dice results available'),
        ...rollEntry.diceResults.entries.map((e) => 
          _buildDieTypeResults(context, e.key, e.value)),
      ],
    );
  }

  /// Builds the results display for a specific die type.
  Widget _buildDieTypeResults(BuildContext context, int sides, List<int> results) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'D$sides (${results.length} dice)',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: results.map((result) => 
              _buildDiceBox(context, size: 46, value: result.toString())
            ).toList(),
          ),
        ],
      ),
    );
  }

  /// Builds the modifier section if a modifier exists.
  Widget _buildModifier(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              const Text(
                'Modifier:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Text(
                rollEntry.modifier > 0
                  ? ' +${rollEntry.modifier}'
                  : '${rollEntry.modifier}',
                style: TextStyle(
                  color: rollEntry.modifier > 0
                    ? Colors.green
                    : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Creates a stylized dice box with the given value.
  Widget _buildDiceBox(
    BuildContext context, {
    required double size,
    required String value,
    double fontSize = 16,
  }) {
    return Transform.rotate(
      angle: 45 * (3.14159 / 180), // 45 degrees in radians
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.8),
              Theme.of(context).primaryColor,
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Center(
          child: Transform.rotate(
            angle: -45 * (3.14159 / 180), // Counter-rotate the text
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}