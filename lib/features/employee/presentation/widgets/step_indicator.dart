import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const StepIndicator({super.key, required this.currentStep, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: List.generate(steps.length, (i) {
          final isCompleted = i < currentStep;
          final isCurrent = i == currentStep;
          final isLast = i == steps.length - 1;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          if (i > 0)
                            Expanded(
                              child: Container(
                                height: 2,
                                color: isCompleted || isCurrent
                                    ? AppTheme.primary
                                    : Colors.grey.shade300,
                              ),
                            ),
                          _StepCircle(
                            index: i + 1,
                            isCompleted: isCompleted,
                            isCurrent: isCurrent,
                          ),
                          if (!isLast)
                            Expanded(
                              child: Container(
                                height: 2,
                                color: isCompleted ? AppTheme.primary : Colors.grey.shade300,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        steps[i],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
                          color: isCurrent
                              ? AppTheme.primary
                              : isCompleted
                                  ? AppTheme.textSecondary
                                  : Colors.grey.shade400,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int index;
  final bool isCompleted;
  final bool isCurrent;

  const _StepCircle({required this.index, required this.isCompleted, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    if (isCompleted) {
      bg = AppTheme.primary;
      fg = Colors.white;
    } else if (isCurrent) {
      bg = AppTheme.primary;
      fg = Colors.white;
    } else {
      bg = Colors.grey.shade200;
      fg = Colors.grey.shade500;
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: isCurrent ? Border.all(color: AppTheme.primary.withOpacity(0.3), width: 3) : null,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
            : Text(
                '$index',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
              ),
      ),
    );
  }
}
