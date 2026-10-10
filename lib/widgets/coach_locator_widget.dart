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
      label:
          'Train Coach Layout on Platform $platform. Your booked coach is $highlightedCoach.',
      container: true,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.view_column_rounded,
                        size: 16,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs + 2),
                    const Text(
                      'Coach Layout',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borderHighlight),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.meeting_room_outlined,
                        size: 13,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Platform $platform',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),

            // Locomotive Direction Hint
            Row(
              children: const [
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 13,
                  color: AppColors.textMuted,
                ),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Engine towards Right ➔ (Tap any coach to view details)',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Scrollable Coach Rake Visualizer
            SizedBox(
              height: 58,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: coaches.length,
                separatorBuilder: (context, i) => Container(
                  width: 6,
                  alignment: Alignment.center,
                  child: Container(
                    height: 2,
                    color: AppColors.borderHighlight,
                  ),
                ),
                itemBuilder: (context, index) {
                  final coach = coaches[index];
                  final isSelected =
                      coach.toUpperCase() == highlightedCoach.toUpperCase();
                  final isLoco = coach == 'LOCO' || coach == 'ENG';

                  return Semantics(
                    button: true,
                    label: isSelected
                        ? 'Coach $coach, your booked coach'
                        : 'Coach $coach',
                    child: InkWell(
                      onTap: () =>
                          _showCoachDetailSheet(context, coach, isSelected),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 54,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : (isLoco
                                  ? AppColors.surfaceContainerHighest
                                  : AppColors.surfaceContainerLow),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.secondaryLight
                                : AppColors.border,
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (isSelected)
                              const Icon(
                                Icons.person_pin_circle_rounded,
                                size: 14,
                                color: Colors.white,
                              )
                            else if (isLoco)
                              const Icon(
                                Icons.power_rounded,
                                size: 13,
                                color: AppColors.textMuted,
                              )
                            else
                              const Icon(
                                Icons.airline_seat_recline_normal_rounded,
                                size: 13,
                                color: AppColors.textMuted,
                              ),
                            const SizedBox(height: 2),
                            Text(
                              coach,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            // Simplified Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(AppColors.primary, 'Your Coach ($highlightedCoach)'),
                const SizedBox(width: AppSpacing.md),
                _buildLegendItem(AppColors.surfaceContainerLow, 'Regular Coach'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: AppColors.borderHighlight, width: 0.8),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
        ),
      ],
    );
  }

  void _showCoachDetailSheet(
      BuildContext context, String coach, bool isYourCoach) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isYourCoach
                              ? AppColors.primary
                              : AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.train_rounded,
                          color: isYourCoach ? Colors.white : AppColors.secondary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Coach $coach',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            isYourCoach
                                ? 'Your Booked Coach'
                                : 'Standard Air-Conditioned Coach',
                            style: TextStyle(
                              fontSize: 12,
                              color: isYourCoach
                                  ? AppColors.secondary
                                  : AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
                        color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(color: AppColors.border),
              const SizedBox(height: AppSpacing.md),
              _buildCoachFeatureRow(Icons.meeting_room_outlined, 'Platform Position',
                  'Mid-train on Platform $platform'),
              const SizedBox(height: AppSpacing.xs),
              _buildCoachFeatureRow(Icons.power_outlined, 'Charging Ports',
                  'Available at every seat (220V + USB-C)'),
              const SizedBox(height: AppSpacing.xs),
              _buildCoachFeatureRow(Icons.accessible_outlined, 'Accessibility',
                  'Wheelchair-friendly wide doors'),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCoachFeatureRow(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.secondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
