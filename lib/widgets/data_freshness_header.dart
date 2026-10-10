import 'package:flutter/material.dart';
import '../services/disruption_service.dart';
import '../theme/app_theme.dart';

class DataFreshnessHeader extends StatelessWidget {
  final DisruptionService disruptionService;

  const DataFreshnessHeader({
    super.key,
    required this.disruptionService,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: disruptionService,
      builder: (context, _) {
        final label = disruptionService.dataFreshnessLabel;
        final isRefreshing = disruptionService.isRefreshing;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              InkWell(
                onTap: isRefreshing ? null : () => disruptionService.refreshData(),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    children: [
                      if (isRefreshing)
                        const SizedBox(
                          width: 11,
                          height: 11,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: AppColors.primary,
                          ),
                        )
                      else
                        const Icon(
                          Icons.sync_rounded,
                          size: 13,
                          color: AppColors.primary,
                        ),
                      const SizedBox(width: 4),
                      const Text(
                        'Refresh',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
