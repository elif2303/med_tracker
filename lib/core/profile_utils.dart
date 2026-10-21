import '../l10n/app_localizations.dart';

/// İsim boşsa (varsayılan profil) yerel dildeki "Ben" gösterilir
String profileLabel(AppLocalizations l10n, String name) =>
    name.trim().isEmpty ? l10n.me : name.trim();