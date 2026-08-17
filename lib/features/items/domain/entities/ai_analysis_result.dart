/// How much to trust the AI-suggested price. Derived server-side from whether
/// the price was grounded in real listings — [low] means ungrounded (a guess).
enum PriceConfidence { high, medium, low }

/// A comparable listing the AI used to anchor the suggested price.
/// Best-effort: [url] is model-authored and may point to a search/category page
/// rather than the exact listing.
class PriceComp {
  final String title;
  final double price;
  final String url;

  const PriceComp({
    required this.title,
    required this.price,
    required this.url,
  });
}

class AiAnalysisResult {
  /// Server-side id of this analysis — the `parent_analysis_id` of a refine.
  /// Null only for legacy/malformed responses.
  final String? analysisId;
  final String name;
  final String? category;
  final String? categoryId;
  final String description;
  final double priceMin;
  final double priceMax;
  final PriceConfidence priceConfidence;
  final List<PriceComp> priceEvidence;

  /// Other plausible identifications (the "Não é isso?" correction chips).
  /// Empty when the model is confident.
  final List<String> alternatives;

  /// The user's correction contradicts the photo (soft warning, never blocks).
  final bool conflictsWithImage;
  final String? conflictNote;

  /// Whether this analysis carries an unspent free retry — drives the
  /// correction-cost copy.
  final bool freeRetryAvailable;

  const AiAnalysisResult({
    this.analysisId,
    required this.name,
    this.category,
    this.categoryId,
    required this.description,
    required this.priceMin,
    required this.priceMax,
    this.priceConfidence = PriceConfidence.low,
    this.priceEvidence = const [],
    this.alternatives = const [],
    this.conflictsWithImage = false,
    this.conflictNote,
    this.freeRetryAvailable = false,
  });

  /// Central price to pre-fill: the midpoint of the (condition-aware) range,
  /// rounded to whole reais — not the floor. The backend already reflects the
  /// item's condition in price_min/price_max, so the midpoint is a sensible
  /// default the user can still adjust.
  double get suggestedPrice => ((priceMin + priceMax) / 2).roundToDouble();
}
