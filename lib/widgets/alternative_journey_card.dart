import 'package:flutter/material.dart';
import '../models/railway_models.dart';
import '../theme/app_theme.dart';

class AlternativeJourneyCard extends StatelessWidget {
  final AlternativeJourney alternative;
  final VoidCallback onSelect;

  const AlternativeJourneyCard({
    super.key,
    required this.alternative,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Train number + Type + Sample simulation badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainerLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.train_rounded, color: AppColors.primary, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${alternative.trainNumber} • ${alternative.trainName}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      alternative.transportType,
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (alternative.isSimulatedSample)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: const Text(
                    'Sample Data',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMutedLight,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Timings & Fare Grid
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('DEPARTURE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    const SizedBox(height: 2),
                    Text(alternative.departureTime, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                    Text(alternative.fromStation.code, style: const TextStyle(fontSize: 10, color: AppColors.textMutedLight)),
                  ],
                ),
                Column(
                  children: [
                    Text(alternative.duration, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('EST. ARRIVAL', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.primary)),
                    const SizedBox(height: 2),
                    Text(alternative.arrivalTime, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                    Text(alternative.toStation.code, style: const TextStyle(fontSize: 10, color: AppColors.textMutedLight)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Availability and Fare Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.successContainerLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  alternative.seatStatus,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSuccessContainerLight,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '₹${alternative.fare.toInt()}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Why Recommended
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_outline_rounded, size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  alternative.recommendationReason,
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Limitations
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.warning),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Limitation: ${alternative.limitationNote}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onSelect,
              icon: const Icon(Icons.open_in_new_rounded, size: 14),
              label: const Text('Proceed to IRCTC Portal to Book'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
