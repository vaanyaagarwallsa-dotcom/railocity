import 'package:flutter/material.dart';

enum AppLanguage {
  english('English', 'en', '🇮🇳'),
  hindi('हिन्दी', 'hi', '🇮🇳'),
  marathi('मराठी', 'mr', '🇮🇳'),
  bengali('বাংলা', 'bn', '🇮🇳'),
  tamil('தமிழ்', 'ta', '🇮🇳'),
  telugu('తెలుగు', 'te', '🇮🇳'),
  gujarati('ગુજરાતી', 'gu', '🇮🇳');

  final String label;
  final String code;
  final String flag;
  const AppLanguage(this.label, this.code, this.flag);
}

class SettingsService extends ChangeNotifier {
  AppLanguage _selectedLanguage = AppLanguage.english;
  AppLanguage get selectedLanguage => _selectedLanguage;

  double _textScale = 1.0;
  double get textScale => _textScale;

  ThemeMode _themeMode = ThemeMode.light; // Warm Ivory Light by default
  ThemeMode get themeMode => _themeMode;

  bool _highContrast = false;
  bool get highContrast => _highContrast;

  bool _offlineDemoMode = true; // Clear demo label
  bool get offlineDemoMode => _offlineDemoMode;

  bool _voiceAssistanceEnabled = true;
  bool get voiceAssistanceEnabled => _voiceAssistanceEnabled;

  bool _reducedMotion = false;
  bool get reducedMotion => _reducedMotion;

  void setLanguage(AppLanguage language) {
    _selectedLanguage = language;
    notifyListeners();
  }

  void setTextScale(double scale) {
    _textScale = scale.clamp(0.9, 1.35);
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleHighContrast(bool enabled) {
    _highContrast = enabled;
    notifyListeners();
  }

  void toggleOfflineDemoMode(bool enabled) {
    _offlineDemoMode = enabled;
    notifyListeners();
  }

  void toggleVoiceAssistance(bool enabled) {
    _voiceAssistanceEnabled = enabled;
    notifyListeners();
  }

  void toggleReducedMotion(bool enabled) {
    _reducedMotion = enabled;
    notifyListeners();
  }

  // Localized strings dictionary for primary UI labels
  String translate(String key) {
    final lang = _selectedLanguage;
    switch (key) {
      case 'home':
        if (lang == AppLanguage.hindi) return 'मुख्य पृष्ठ';
        if (lang == AppLanguage.marathi) return 'मुख्य पृष्ठ';
        if (lang == AppLanguage.bengali) return 'হোম';
        if (lang == AppLanguage.tamil) return 'முகப்பு';
        if (lang == AppLanguage.gujarati) return 'મુખ્ય';
        return 'Home';
      case 'disruptions':
        if (lang == AppLanguage.hindi) return 'व्यवधान विवरण';
        if (lang == AppLanguage.bengali) return 'ব্যাহত বিবরণ';
        return 'Disruptions';
      case 'ai_recovery':
        if (lang == AppLanguage.hindi) return 'एआई रिकवरी';
        if (lang == AppLanguage.bengali) return 'এআই রিকভারি';
        return 'AI Recovery';
      case 'alerts':
        if (lang == AppLanguage.hindi) return 'सूचनाएं';
        if (lang == AppLanguage.bengali) return 'সতর্কতা';
        return 'Alerts';
      case 'settings':
        if (lang == AppLanguage.hindi) return 'सेटिंग्स';
        if (lang == AppLanguage.bengali) return 'সেটিংস';
        return 'Settings';
      default:
        return key;
    }
  }
}
