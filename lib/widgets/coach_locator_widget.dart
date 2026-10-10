import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CoachLocatorWidget extends StatelessWidget {
  final List<String> coaches;
  final String highlightedCoach;
  final int platform;

  const CoachLocatorWidget({
    super.key,
    required this.coaches,
    this.highlightedCoach = 'B3',
    required this.platform,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Train Coach Layout on Platform $platform. Your coach is $highlightedCoach.',
      container: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainerLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.view_column_rounded, size: 16, color: AppColors.primary),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Coach Position on Platform',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: Text(
                    'Platform $platform',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            Row(
              children: [
                const Icon(Icons.arrow_forward_rounded, size: 12, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  'Engine / Direction of Travel',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xs),

            // Coach Horizontal Strip
            SizedBox(
              height: 58,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: coaches.length,
                separatorBuilder: (context, index) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final coach = coaches[index];
                  final isTarget = coach.toUpperCase() == highlightedCoach.toUpperCase();
                  final isLoco = coach == 'LOCO' || coach == 'ENG';

                  return Container(
                    width: 52,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isTarget
                          ? AppColors.primary
                          : (isLoco ? Theme.of(context).colorScheme.surfaceContainerHigh : Theme.of(context).colorScheme.surfaceContainerLow),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isTarget ? AppColors.primaryDark : Theme.of(context).colorScheme.outlineVariant,
                        width: isTarget ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isLoco ? Icons.electric_bolt_rounded : Icons.crop_square_rounded,
                          size: 14,
                          color: isTarget ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          coach,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isTarget ? Colors.white : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.xs),

            Text(
              '💡 Your Coach $highlightedCoach will halt near Escalator B & Foot Overbridge #2 ramp.',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
