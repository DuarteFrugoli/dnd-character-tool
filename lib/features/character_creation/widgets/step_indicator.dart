import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.totalSteps,
    required this.currentStep,
  });

  final int totalSteps;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final track = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(totalSteps * 2 - 1, (i) {
          if (i.isOdd) {
            // Linha de conexão
            return Expanded(
              child: Container(
                height: 2,
                color: i ~/ 2 < currentStep ? color : track,
              ),
            );
          }
          final step = i ~/ 2;
          final done = step < currentStep;
          final active = step == currentStep;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done || active ? color : track,
            ),
            child: Center(
              child: done
                  ? Icon(
                      Icons.check,
                      size: 14,
                      color: Theme.of(context).colorScheme.onPrimary,
                    )
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: active
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
          );
        }),
      ),
    );
  }
}
