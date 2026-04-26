class PlanUsage {
  final int used;
  final int? max;

  const PlanUsage({required this.used, required this.max});

  bool get isUnlimited => max == null;

  double get fraction {
    if (max == null || max == 0) return 0;
    return (used / max!).clamp(0.0, 1.0);
  }
}
