import 'package:circulari_ui/circulari_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:circulari/core/models/plan_tier.dart';
import 'package:circulari/features/subscription/domain/entities/subscription_option.dart';
import 'package:circulari/features/subscription/presentation/bloc/paywall_bloc.dart';
import 'package:circulari/features/subscription/presentation/bloc/paywall_event.dart';
import 'package:circulari/features/subscription/presentation/bloc/paywall_state.dart';

/// The "Planos" paywall.
///
/// Card copy (name, subtitle, features) is app-owned static content — RevenueCat
/// doesn't provide it. Price and the purchasable package come from the live
/// offering ([PaywallBloc]); until the products are configured in RevenueCat the
/// cards fall back to [_planCatalog]'s mock prices with their buttons disabled.
class PlansPage extends StatefulWidget {
  const PlansPage({super.key});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage>
    with SingleTickerProviderStateMixin {
  // Card width is [screenWidth - _cardMargin]; [_gap] is the empty gutter
  // between two cards. Making the page slot narrower than the screen lets the
  // neighbouring cards peek in on both sides.
  static const _cardMargin = 50.0;
  static const _gap = 12.0;

  // Fallback height used until the cards have reported their measured height.
  static const _fallbackHeight = 420.0;

  PageController? _controller;
  late final TabController _tabController;
  BillingPeriod _period = BillingPeriod.monthly;
  int _currentPage = 0;
  final _cardHeights = <int, double>{};

  /// Package currently being purchased, so the spinner shows on the right card.
  String? _purchasingId;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: BillingPeriod.values.length, vsync: this)
          ..addListener(_onTabChanged);
  }

  void _onTabChanged() {
    final period = BillingPeriod.values[_tabController.index];
    if (period != _period) setState(() => _period = period);
  }

  /// Height of the tallest measured card (or a fallback before measurement).
  double get _carouselHeight => _cardHeights.isEmpty
      ? _fallbackHeight
      : _cardHeights.values.reduce((a, b) => a > b ? a : b);

  void _reportHeight(int index, double height) {
    if (!mounted || _cardHeights[index] == height) return;
    setState(() => _cardHeights[index] = height);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncController();
  }

  @override
  void reassemble() {
    // Hot reload keeps the old controller (and its old viewportFraction), so
    // re-sync it here as well.
    super.reassemble();
    _syncController();
  }

  /// Recreates the controller whenever the target [viewportFraction] changes
  /// (first build, screen resize, or hot reload).
  void _syncController() {
    final width = MediaQuery.of(context).size.width;
    // page step = cardWidth + _gap = (width - _cardMargin) + _gap
    final fraction = ((width - _cardMargin + _gap) / width)
        .clamp(0.1, 1.0)
        .toDouble();
    if (_controller != null && _controller!.viewportFraction == fraction) {
      return;
    }
    final old = _controller;
    _controller = PageController(
      viewportFraction: fraction,
      initialPage: _currentPage,
    );
    if (old != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  /// One-shot reactions to a completed purchase/restore or a surfaced error.
  void _onPaywallState(BuildContext context, PaywallState state) {
    if (state is! PaywallReady) return;
    if (state.purchasedTier != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Plano ${state.purchasedTier!.displayName} ativado!'),
        ),
      );
      context.pop(true);
    } else if (state.error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(state.error!)));
      setState(() => _purchasingId = null);
    }
  }

  /// The live option for [tier] in the selected period, or null when offerings
  /// haven't loaded (or that combination isn't sold).
  SubscriptionOption? _optionFor(PaywallState state, PlanTier tier) {
    if (state is! PaywallReady) return null;
    for (final option in state.options) {
      if (option.tier == tier && option.period == _period) return option;
    }
    return null;
  }

  void _purchase(String packageId) {
    setState(() => _purchasingId = packageId);
    context.read<PaywallBloc>().add(PaywallPurchaseRequested(packageId));
  }

  Widget _buildCard(PaywallState state, _PlanInfo plan, bool busy) {
    final option = _optionFor(state, plan.tier);
    final price = option?.priceString ?? plan.mockPrice(_period);

    VoidCallback? onPressed;
    var isLoading = false;
    if (option != null) {
      isLoading = busy && _purchasingId == option.packageId;
      onPressed = busy ? null : () => _purchase(option.packageId);
    }
    // Paid tier without a loaded option → button stays disabled (mock preview).

    return _PlanCard(
      plan: plan,
      period: _period,
      price: price,
      onPressed: onPressed,
      isLoading: isLoading,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.of(context).size.width - _cardMargin;

    return CirculariInAppScaffold(
      title: 'Planos',
      body: SafeArea(
        top: false,
        child: BlocConsumer<PaywallBloc, PaywallState>(
          listenWhen: (previous, current) => current is PaywallReady,
          listener: _onPaywallState,
          builder: (context, state) {
            final busy = state is PaywallReady && state.busy;

            return Column(
              children: [
                // Measures every card off-screen so the carousel height is
                // fixed from the first frame — the tallest card never resizes
                // the PageView the first time it scrolls into view.
                _CardMeasurements(
                  plans: _planCatalog,
                  period: _period,
                  cardWidth: cardWidth,
                  onHeight: _reportHeight,
                ),
                const SizedBox(height: 8),
                _BillingToggle(controller: _tabController),
                const SizedBox(height: 32),
                // Carousel is sized to the tallest card so the page indicator
                // sits right beneath it; every card fills that height, so they
                // are all the same fixed size. Flexible lets it shrink (cards
                // scroll) if a card is taller than the space available.
                Flexible(
                  child: SizedBox(
                    height: _carouselHeight,
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: _planCatalog.length,
                      onPageChanged: (index) =>
                          setState(() => _currentPage = index),
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: _gap / 2),
                        child: _buildCard(state, _planCatalog[index], busy),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _PageIndicator(
                  count: _planCatalog.length,
                  current: _currentPage,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: (state is! PaywallReady || busy)
                      ? null
                      : () => context
                          .read<PaywallBloc>()
                          .add(const PaywallRestoreRequested()),
                  child: const Text('Restaurar compras'),
                ),
                const SizedBox(height: 8),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Billing period toggle (Mensal / Anual)
// ---------------------------------------------------------------------------

class _BillingToggle extends StatelessWidget {
  final TabController controller;

  const _BillingToggle({required this.controller});

  @override
  Widget build(BuildContext context) {
    final typography = context.circulariTheme.typography;
    final labelStyle = typography.body.medium.medium.copyWith(
      fontSize: 14,
      height: 1,
      letterSpacing: 0,
    );

    return Container(
      width: 260,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: CirculariColorsTokens.greyscale300,
        borderRadius: BorderRadius.circular(40),
      ),
      child: TabBar(
        controller: controller,
        // The pill fills the whole tab and slides between them.
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: EdgeInsets.zero,
        indicator: BoxDecoration(
          color: CirculariColorsTokens.freshCore,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: CirculariColorsTokens.freshCore.withValues(alpha: 0.5),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
        dividerColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        labelColor: CirculariColorsTokens.greyscale900,
        unselectedLabelColor: CirculariColorsTokens.greyscale500,
        labelStyle: labelStyle,
        unselectedLabelStyle: labelStyle,
        tabs: const [
          Tab(height: 40, text: 'Mensal'),
          Tab(height: 40, text: 'Anual'),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Plan card
// ---------------------------------------------------------------------------

class _PlanCard extends StatelessWidget {
  final _PlanInfo plan;
  final BillingPeriod period;

  /// Resolved display price (live price, or the mock fallback).
  final String price;

  /// Null → the CTA is disabled (paid tier whose offering hasn't loaded yet).
  final VoidCallback? onPressed;
  final bool isLoading;

  /// Reports the card's natural height (content + vertical padding) so the
  /// carousel can size itself to the tallest card.
  final ValueChanged<double>? onHeight;

  const _PlanCard({
    required this.plan,
    required this.period,
    required this.price,
    this.onPressed,
    this.isLoading = false,
    this.onHeight,
  });

  static const _cardColor = Color(0xFF1E1E1E);
  static const _verticalPadding = 32.0;

  @override
  Widget build(BuildContext context) {
    final typography = context.circulariTheme.typography;
    final suffix = period == BillingPeriod.monthly ? '/mês' : '/ano';

    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 28,
          vertical: _verticalPadding,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Bounded height → the on-screen card: fill it and push the button
            // to the bottom. Unbounded → the off-screen measurement pass: stay
            // min-sized so we measure the natural content height.
            final filled = constraints.maxHeight.isFinite;
            return _MeasureSize(
              onChange: (size) =>
                  onHeight?.call(size.height + 2 * _verticalPadding),
              child: Column(
                mainAxisSize: filled ? MainAxisSize.max : MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.name.toUpperCase(),
                    style: typography.body.medium.bold.copyWith(
                      color: CirculariColorsTokens.freshCore,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: price,
                          style: typography.body.large.semibold.copyWith(
                            fontSize: 32,
                            height: 1.2,
                            letterSpacing: 0,
                            color: CirculariColorsTokens.greyscale50,
                          ),
                        ),
                        TextSpan(
                          text: suffix,
                          style: typography.body.large.bold.copyWith(
                            fontSize: 20,
                            height: 36 / 20,
                            letterSpacing: 0.7,
                            color: CirculariColorsTokens.greyscale50,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    plan.subtitle.toUpperCase(),
                    style: typography.body.small.medium.copyWith(
                      color: CirculariColorsTokens.greyscale400,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Divider(
                    color: Colors.white.withValues(alpha: 0.12),
                    height: 1,
                  ),
                  const SizedBox(height: 24),
                  for (final feature in plan.features) ...[
                    _FeatureRow(text: feature),
                    const SizedBox(height: 12),
                  ],
                  if (filled) const Spacer() else const SizedBox(height: 12),
                  CirculariButton(
                    label: plan.ctaLabel,
                    isLoading: isLoading,
                    onPressed: onPressed,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  /// Feature text with optional `**bold**` segments.
  final String text;

  const _FeatureRow({required this.text});

  @override
  Widget build(BuildContext context) {
    final typography = context.circulariTheme.typography;
    final base = typography.body.medium.regular.copyWith(
      color: CirculariColorsTokens.greyscale100,
      fontSize: 14,
      height: 20 / 14,
      letterSpacing: 0,
    );
    final bold = typography.body.medium.bold.copyWith(
      color: CirculariColorsTokens.greyscale50,
      fontSize: 14,
      height: 20 / 14,
      letterSpacing: 0,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(
            Icons.check_rounded,
            size: 20,
            color: CirculariColorsTokens.freshCore,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text.rich(
            TextSpan(children: _parseBold(text, base: base, bold: bold)),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Off-screen measurement
// ---------------------------------------------------------------------------

/// Lays out every card off-screen (zero layout footprint) at the real card
/// width, reporting each one's natural height via [onHeight]. This lets the
/// carousel fix its height before any card scrolls into view.
class _CardMeasurements extends StatelessWidget {
  final List<_PlanInfo> plans;
  final BillingPeriod period;
  final double cardWidth;
  final void Function(int index, double height) onHeight;

  const _CardMeasurements({
    required this.plans,
    required this.period,
    required this.cardWidth,
    required this.onHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Offstage(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < plans.length; i++)
            SizedBox(
              width: cardWidth,
              child: _PlanCard(
                plan: plans[i],
                period: period,
                price: plans[i].mockPrice(period),
                onHeight: (height) => onHeight(i, height),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Size measurement helper
// ---------------------------------------------------------------------------

/// Reports its child's laid-out size via [onChange] after each layout. Placed
/// inside a vertically-scrolling parent, the child lays out at its natural
/// height, so this yields the card's intrinsic height.
class _MeasureSize extends SingleChildRenderObjectWidget {
  final ValueChanged<Size> onChange;

  const _MeasureSize({required this.onChange, required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _MeasureSizeRenderObject(onChange);

  @override
  void updateRenderObject(
    BuildContext context,
    _MeasureSizeRenderObject renderObject,
  ) {
    renderObject.onChange = onChange;
  }
}

class _MeasureSizeRenderObject extends RenderProxyBox {
  _MeasureSizeRenderObject(this.onChange);

  ValueChanged<Size> onChange;
  Size? _oldSize;

  @override
  void performLayout() {
    super.performLayout();
    final newSize = child?.size ?? Size.zero;
    if (_oldSize == newSize) return;
    _oldSize = newSize;
    WidgetsBinding.instance.addPostFrameCallback((_) => onChange(newSize));
  }
}

// ---------------------------------------------------------------------------
// Page indicator
// ---------------------------------------------------------------------------

class _PageIndicator extends StatelessWidget {
  final int count;
  final int current;

  const _PageIndicator({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 20,
            height: 4,
            decoration: BoxDecoration(
              color: i == current
                  ? CirculariColorsTokens.freshCore
                  : CirculariColorsTokens.greyscale300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Static plan catalog (app-owned copy + mock price fallback)
// ---------------------------------------------------------------------------

/// Splits [text] on `**` markers into alternating [base]/[bold] spans.
List<InlineSpan> _parseBold(
  String text, {
  required TextStyle base,
  required TextStyle bold,
}) {
  final parts = text.split('**');
  final spans = <InlineSpan>[];
  for (var i = 0; i < parts.length; i++) {
    if (parts[i].isEmpty) continue;
    spans.add(TextSpan(text: parts[i], style: i.isOdd ? bold : base));
  }
  return spans;
}

class _PlanInfo {
  final PlanTier tier;
  final String name;
  final String subtitle;
  final List<String> features;
  final String ctaLabel;

  /// Prices shown until the live offering loads (or when it doesn't sell this
  /// tier). The live [SubscriptionOption.priceString] overrides these.
  final String mockMonthlyPrice;
  final String mockAnnualPrice;

  const _PlanInfo({
    required this.tier,
    required this.name,
    required this.subtitle,
    required this.features,
    required this.ctaLabel,
    required this.mockMonthlyPrice,
    required this.mockAnnualPrice,
  });

  String mockPrice(BillingPeriod period) =>
      period == BillingPeriod.monthly ? mockMonthlyPrice : mockAnnualPrice;
}

const _planCatalog = <_PlanInfo>[
  _PlanInfo(
    tier: PlanTier.essencial,
    name: 'Essencial',
    subtitle: 'Para quem quer organizar mais',
    mockMonthlyPrice: r'R$14,90',
    mockAnnualPrice: r'R$149,90',
    features: [
      'Até **500 itens**',
      'Uso de IA para a criação de até **100 itens**',
      'Crie até **10 listas**',
      'Procura de itens avançada',
    ],
    ctaLabel: 'Assinar',
  ),
  _PlanInfo(
    tier: PlanTier.pro,
    name: 'Pro',
    subtitle: 'Acesso total e ilimitado',
    mockMonthlyPrice: r'R$29,90',
    mockAnnualPrice: r'R$299,90',
    features: [
      '**Itens ilimitados**',
      '**IA ilimitada** para criação de itens',
      '**Listas ilimitadas**',
      'Procura de itens com IA',
      'Suporte prioritário',
    ],
    ctaLabel: 'Assinar',
  ),
];
