import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../services/disruption_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsService settingsService;
  final DisruptionService disruptionService;

  const SettingsScreen({
    super.key,
    required this.settingsService,
    required this.disruptionService,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([settingsService, disruptionService]),
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainerLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.settings_outlined, color: AppColors.primary, size: 16),
                ),
                const SizedBox(width: 8),
                const Text('Settings & Accessibility'),
              ],
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              // 1. DEMO SCENARIO SIMULATOR (Essential for demonstration & testing)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainerLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.science_rounded, size: 16, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text(
                          'INTERACTIVE DISRUPTION SIMULATOR',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Simulate realistic Indian Railways disruption scenarios in real-time:',
                      style: TextStyle(fontSize: 12, height: 1.3),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildScenarioTile(
                      context,
                      title: 'Scenario 1: Missed Connecting Train (High Risk)',
                      subtitle: '55m delay on 12952 eats 70m transfer buffer at Vadodara (15m left) ➔ Triggers TDR refund & 3 alternatives',
                      scenario: DemoScenario.missedConnectionRisk,
                    ),
                    _buildScenarioTile(
                      context,
                      title: 'Scenario 2: Urgent Platform Shift (Platform 2 ➔ 4)',
                      subtitle: 'Platform reallocation at Mathura Jn with FOB ramp & accessibility walking guidance',
                      scenario: DemoScenario.urgentPlatformShift,
                    ),
                    _buildScenarioTile(
                      context,
                      title: 'Scenario 3: Northern Fog Delay (42m)',
                      subtitle: 'Regulated speed under fog safety protocols with speed catch-up telemetry',
                      scenario: DemoScenario.fogDelayRecovery,
                    ),
                    _buildScenarioTile(
                      context,
                      title: 'Scenario 4: Train Cancellation & Automatic Refund',
                      subtitle: 'Section modernization cancellation with Section 54 automatic refund guidance',
                      scenario: DemoScenario.trainCancelledTDR,
                    ),
                    _buildScenarioTile(
                      context,
                      title: 'Scenario 5: On-Time Smooth Journey (0 min delay)',
                      subtitle: 'Cruising at 115 km/h on green signal corridor with all buffers safe',
                      scenario: DemoScenario.onTimeSmoothTrip,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // 2. LANGUAGE & LOCALIZATION
              const Text(
                'Language & Multilingual Support',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: Column(
                  children: AppLanguage.values.map((lang) {
                    final isSelected = settingsService.selectedLanguage == lang;
                    return ListTile(
                      dense: true,
                      leading: Text(lang.flag, style: const TextStyle(fontSize: 18)),
                      title: Text(lang.label, style: TextStyle(fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500)),
                      subtitle: Text(lang.code.toUpperCase(), style: const TextStyle(fontSize: 10)),
                      trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 18) : null,
                      onTap: () => settingsService.setLanguage(lang),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // 3. ACCESSIBILITY & DISPLAY
              const Text(
                'Display & Accessibility',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.xs),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    // Text scale selector
                    ListTile(
                      title: const Text('Text Size Scaling', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      subtitle: Text('Current scale: ${(settingsService.textScale * 100).toInt()}%'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Row(
                        children: [
                          const Text('A', style: TextStyle(fontSize: 12)),
                          Expanded(
                            child: Slider(
                              value: settingsService.textScale,
                              min: 0.9,
                              max: 1.30,
                              divisions: 4,
                              activeColor: AppColors.primary,
                              onChanged: (val) => settingsService.setTextScale(val),
                            ),
                          ),
                          const Text('A', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('High Contrast Mode', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Enhance borders and text contrast for outdoor visibility', style: TextStyle(fontSize: 11)),
                      value: settingsService.highContrast,
                      activeColor: AppColors.primary,
                      onChanged: (val) => settingsService.toggleHighContrast(val),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      title: const Text('Theme Mode', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: Text(settingsService.themeMode == ThemeMode.dark ? 'Slate Dark Mode' : 'Warm Ivory Light Mode', style: const TextStyle(fontSize: 11)),
                      value: settingsService.themeMode == ThemeMode.dark,
                      activeColor: AppColors.primary,
                      onChanged: (val) => settingsService.setThemeMode(val ? ThemeMode.dark : ThemeMode.light),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // 4. DATA INTEGRITY & ABOUT
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Railocity • AI-Powered Disruption Assistance',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Version 0.1.0 • Built with Material 3 & Indian Railways Commercial Rules Section 54.\n'
                      'Data feeds verified via NTES Live with deterministic connection transfer window calculation.',
                      style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant, height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScenarioTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required DemoScenario scenario,
  }) {
    final isCurrent = disruptionService.currentScenario == scenario;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.primary : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrent ? AppColors.primaryDark : Theme.of(context).colorScheme.outlineVariant,
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isCurrent ? Colors.white : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 10,
            color: isCurrent ? Colors.white.withOpacity(0.9) : Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.3,
          ),
        ),
        trailing: isCurrent
            ? const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18)
            : const Icon(Icons.play_circle_outline_rounded, size: 18, color: AppColors.primary),
        onTap: () {
          disruptionService.switchScenario(scenario);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Switched to: $title'),
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
    );
  }
}
