import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:circulari/features/items/domain/entities/ai_analysis_result.dart';

/// Shows the AI price-confidence badge and, when present, the comparable
/// listings the estimate was anchored to (expandable, tappable). The listing
/// links are best-effort (model-authored) — hence the disclaimer.
class PriceInsight extends StatefulWidget {
  final AiAnalysisResult analysis;
  const PriceInsight({super.key, required this.analysis});

  @override
  State<PriceInsight> createState() => _PriceInsightState();
}

class _PriceInsightState extends State<PriceInsight> {
  bool _expanded = false;
  final _priceFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ');

  ({String label, Color color}) get _confidence =>
      switch (widget.analysis.priceConfidence) {
        PriceConfidence.high => (
          label: 'Alta confiança',
          color: CirculariColorsTokens.freshCore500,
        ),
        PriceConfidence.medium => (
          label: 'Média confiança',
          color: CirculariColorsTokens.solarPulse400,
        ),
        PriceConfidence.low => (
          label: 'Baixa confiança',
          color: CirculariColorsTokens.greyscale400,
        ),
      };

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    final ok =
        uri != null &&
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o link.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final typography = context.circulariTheme.typography;
    final conf = _confidence;
    final comps = widget.analysis.priceEvidence;
    final hasComps = comps.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: CirculariColorsTokens.greyscale200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ConfidenceBadge(label: conf.label, color: conf.color),
              const Spacer(),
              if (hasComps)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Row(
                    children: [
                      Text(
                        'Baseado em ${comps.length} '
                        '${comps.length == 1 ? 'anúncio' : 'anúncios'}',
                        style: typography.body.small.medium.copyWith(
                          color: CirculariColorsTokens.greyscale600,
                        ),
                      ),
                      Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        size: 18,
                        color: CirculariColorsTokens.greyscale500,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (!hasComps)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Estimativa sem anúncios de referência.',
                style: typography.body.xSmall.regular.copyWith(
                  color: CirculariColorsTokens.greyscale500,
                ),
              ),
            ),
          if (hasComps && _expanded) ...[
            const SizedBox(height: 8),
            for (final c in comps)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _openUrl(c.url),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: typography.body.small.regular.copyWith(
                            color: CirculariColorsTokens.greyscale700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _priceFmt.format(c.price),
                        style: typography.body.small.semibold.copyWith(
                          color: CirculariColorsTokens.greyscale900,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.north_east,
                        size: 14,
                        color: CirculariColorsTokens.greyscale500,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 6),
            Text(
              'Referências aproximadas; os links podem levar a buscas.',
              style: typography.body.xSmall.regular.copyWith(
                color: CirculariColorsTokens.greyscale500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _ConfidenceBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: context.circulariTheme.typography.body.xSmall.semibold
                .copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
