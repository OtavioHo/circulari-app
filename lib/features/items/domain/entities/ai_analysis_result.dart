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
  final String name;
  final String? category;
  final String? categoryId;
  final String description;
  final double priceMin;
  final double priceMax;
  final PriceConfidence priceConfidence;
  final List<PriceComp> priceEvidence;

  const AiAnalysisResult({
    required this.name,
    this.category,
    this.categoryId,
    required this.description,
    required this.priceMin,
    required this.priceMax,
    this.priceConfidence = PriceConfidence.low,
    this.priceEvidence = const [],
  });
}
