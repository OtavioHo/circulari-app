class AiAnalysisResult {
  final String name;
  final String? category;
  final String? categoryId;
  final String description;
  final double priceMin;
  final double priceMax;

  const AiAnalysisResult({
    required this.name,
    this.category,
    this.categoryId,
    required this.description,
    required this.priceMin,
    required this.priceMax,
  });
}
