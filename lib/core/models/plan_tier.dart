/// The three subscription tiers, mirrored from the backend `users.tier`.
enum PlanTier { free, essencial, pro }

extension PlanTierX on PlanTier {
  String get apiValue => switch (this) {
        PlanTier.free => 'free',
        PlanTier.essencial => 'essencial',
        PlanTier.pro => 'pro',
      };

  String get displayName => switch (this) {
        PlanTier.free => 'Free',
        PlanTier.essencial => 'Essencial',
        PlanTier.pro => 'Pro',
      };

  bool get isPaid => this != PlanTier.free;

  /// Ordering so a higher tier can be compared against a lower one.
  int get rank => switch (this) {
        PlanTier.free => 0,
        PlanTier.essencial => 1,
        PlanTier.pro => 2,
      };
}

/// Parses the backend tier string. Legacy `premium` maps to [PlanTier.pro];
/// anything unknown is treated as [PlanTier.free].
PlanTier planTierFromString(String? raw) => switch (raw?.toLowerCase()) {
      'pro' || 'premium' => PlanTier.pro,
      'essencial' => PlanTier.essencial,
      _ => PlanTier.free,
    };

/// Maps a RevenueCat product or entitlement identifier to a tier by matching
/// the tier name as a substring (e.g. `com.circulari.pro.monthly`, or the
/// entitlement id `pro`). Returns null when no tier name is present.
PlanTier? planTierFromIdentifier(String identifier) {
  final lower = identifier.toLowerCase();
  if (lower.contains('pro')) return PlanTier.pro;
  if (lower.contains('essencial')) return PlanTier.essencial;
  return null;
}
