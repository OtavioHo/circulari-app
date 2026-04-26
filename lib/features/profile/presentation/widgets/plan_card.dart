import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/plan_usage.dart';
import '../../domain/entities/user_plan.dart';

class PlanCard extends StatelessWidget {
  final UserPlan plan;

  const PlanCard({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final typography = context.circulariTheme.typography;
    final spacing = context.circulariTheme.spacing;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: spacing.medium),
      padding: EdgeInsets.all(spacing.medium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: plan.isPremium
                      ? CirculariColorsTokens.solarPulse100
                      : CirculariColorsTokens.freshCore100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      plan.isPremium ? Icons.star_rounded : Icons.lock_outline_rounded,
                      size: 16,
                      color: plan.isPremium
                          ? CirculariColorsTokens.solarPulse500
                          : CirculariColorsTokens.freshCore600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      plan.isPremium ? 'Premium' : 'Free',
                      style: typography.body.small.bold.copyWith(
                        color: plan.isPremium
                            ? CirculariColorsTokens.solarPulse500
                            : CirculariColorsTokens.freshCore600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (!plan.isPremium)
                Text(
                  'Upgrade →',
                  style: typography.body.small.semibold.copyWith(
                    color: CirculariColorsTokens.solarPulse400,
                  ),
                ),
            ],
          ),
          SizedBox(height: spacing.small),
          const Divider(color: CirculariColorsTokens.greyscale200),
          SizedBox(height: spacing.small),
          _UsageRow(
            icon: Icons.list_alt_rounded,
            label: 'Listas',
            usage: plan.lists,
            typography: typography,
          ),
          SizedBox(height: spacing.small),
          _UsageRow(
            icon: Icons.inventory_2_outlined,
            label: 'Itens',
            usage: plan.items,
            typography: typography,
          ),
          SizedBox(height: spacing.small),
          _UsageRow(
            icon: Icons.auto_awesome_outlined,
            label: 'Chamadas de IA',
            usage: plan.aiCalls,
            typography: typography,
          ),
        ],
      ),
    );
  }
}

class _UsageRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final PlanUsage usage;
  final CirculariTypography typography;

  const _UsageRow({
    required this.icon,
    required this.label,
    required this.usage,
    required this.typography,
  });

  Color _barColor(double fraction) {
    if (fraction >= 1.0) return const Color(0xFFE53935);
    if (fraction >= 0.8) return CirculariColorsTokens.solarPulse400;
    return CirculariColorsTokens.freshCore500;
  }

  @override
  Widget build(BuildContext context) {
    final fraction = usage.isUnlimited ? 1.0 : usage.fraction;
    final barColor = usage.isUnlimited
        ? CirculariColorsTokens.freshCore500
        : _barColor(fraction);

    final usageText = usage.isUnlimited
        ? '${usage.used} / ∞'
        : '${usage.used} / ${usage.max}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: CirculariColorsTokens.greyscale500),
            const SizedBox(width: 6),
            Text(
              label,
              style: typography.body.small.medium.copyWith(
                color: CirculariColorsTokens.greyscale700,
              ),
            ),
            const Spacer(),
            Text(
              usageText,
              style: typography.body.small.regular.copyWith(
                color: CirculariColorsTokens.greyscale500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: usage.isUnlimited ? 1.0 : fraction,
            minHeight: 6,
            backgroundColor: CirculariColorsTokens.greyscale200,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}
