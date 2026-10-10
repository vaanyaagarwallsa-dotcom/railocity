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
          border: Border.all(color: AppColors.border, width: 1.2),
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
                        size: 18,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs + 2),
                    const Text(
                      'Coach Layout & Position',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 5,
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
                        size: 14,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Platform $platform',
                        style: const TextStyle(
                          fontSize: 12,
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
              children: [
                const Icon(
                  Icons.arrow_forward_rounded,
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                const Expanded(
                  child: Text(
                    'Train movement: Left ➔ Right (Engine at head). Tap any coach for details:',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Scrollable Coach Rake Visualizer
            SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: coaches.length,
                separatorBuilder: (context, i) => Container(
                  width: 8,
                  alignment: Alignment.center,
                  child: Container(
                    height: 3,
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
                      onTap: () => _showCoachDetailSheet(context, coach, isSelected),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 58,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : (isLoco
                                  ? AppColors.surfaceContainerHighest
                                  : AppColors.surfaceContainerLow),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.secondary
                                : AppColors.borderHighlight,
                            width: isSelected ? 2.2 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.5),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isLoco
                                  ? Icons.electric_bolt_rounded
                                  : (isSelected
                                      ? Icons.airline_seat_recline_extra_rounded
                                      : Icons.airline_seat_recline_normal_rounded),
                              size: 18,
                              color: isSelected
                                  ? Colors.white
                                  : (isLoco
                                      ? AppColors.tertiary
                                      : AppColors.textSecondary),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              coach,
                              style: TextStyle(
                                fontSize: 13,
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

            const SizedBox(height: AppSpacing.md),

            // Platform Facilities Guide (Accessibility Focus)
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.accessibility_new_rounded,
                      size: 18,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coach $highlightedCoach Accessibility Guide:',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Halts approx. 95m from Center FOB (Foot Over Bridge #2). Escalator A & Wheelchair Ramp access direct to coach doorway.',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCoachDetailSheet(
      BuildContext context, String coach, bool isYourCoach) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                              : AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.train_rounded,
                          color: isYourCoach ? Colors.white : AppColors.secondary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Coach $coach Details',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (isYourCoach)
                            const Text(
                              'YOUR BOOKED COACH',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(color: AppColors.border),
              const SizedBox(height: AppSpacing.sm),
              _buildCoachFeatureItem(
                icon: Icons.electrical_services_rounded,
                title: 'Charging Points',
                subtitle: 'Individual 220V AC & USB fast-charge sockets at every berth',
              ),
              _buildCoachFeatureItem(
                icon: Icons.wc_rounded,
                title: 'Bio-Vacuum Toilets',
                subtitle: 'Accessible washrooms located at both ends of coach',
              ),
              _buildCoachFeatureItem(
                icon: Icons.ac_unit_rounded,
                title: 'Climate Control',
                subtitle: 'Maintained at 22°C with automated fresh-air cycles',
              ),
              _buildCoachFeatureItem(
                icon: Icons.emergency_rounded,
                title: 'Emergency Exit',
                subtitle: 'Emergency windows located near berths 19, 20 & 43, 44',
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCoachFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.secondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
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
