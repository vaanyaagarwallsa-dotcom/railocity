import 'package:flutter/material.dart';
import '../models/railway_models.dart';
import '../theme/app_theme.dart';

class VerifiedSourceBadge extends StatelessWidget {
  final VerificationSource source;
  final String? customLabel;

  const VerifiedSourceBadge({
    super.key,
    required this.source,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    IconData icon;
    String label = customLabel ?? '';

    switch (source) {
      case VerificationSource.ntesLive:
        bg = AppColors.successContainerLight;
        fg = AppColors.onSuccessContainerLight;
        icon = Icons.verified_rounded;
        if (label.isEmpty) label = 'NTES Live Verified';
        break;
      case VerificationSource.stationMaster:
        bg = AppColors.primaryContainerLight;
        fg = AppColors.onPrimaryContainerLight;
        icon = Icons.account_balance_rounded;
        if (label.isEmpty) label = 'Station Master Verified';
        break;
      case VerificationSource.railocityEstimate:
        bg = AppColors.warningContainerLight;
        fg = AppColors.onWarningContainerLight;
        icon = Icons.auto_awesome_rounded;
        if (label.isEmpty) label = 'Railocity AI Estimate';
        break;
      case VerificationSource.passengerReport:
        bg = AppColors.surfaceContainerHighLight;
        fg = AppColors.textSecondaryLight;
        icon = Icons.person_outline_rounded;
        if (label.isEmpty) label = 'Unverified Report';
        break;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      if (source == VerificationSource.ntesLive) {
        bg = AppColors.successContainerDark;
        fg = AppColors.onSuccessContainerDark;
      } else if (source == VerificationSource.stationMaster) {
        bg = AppColors.primaryContainerDark;
        fg = AppColors.onPrimaryContainerDark;
      } else if (source == VerificationSource.railocityEstimate) {
        bg = AppColors.warningContainerDark;
        fg = AppColors.onWarningContainerDark;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withOpacity(0.3), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: fg,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
