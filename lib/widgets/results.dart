import 'package:flutter/material.dart';

class RollResultDisplay extends StatelessWidget {
  final int result;
  final int sides;

  const RollResultDisplay({
    super.key,
    required this.result,
    required this.sides,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              result.toString(),
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Text(
              'd$sides',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
    );
  }
}