# Testing subscriptions end-to-end on Android

How to exercise the full RevenueCat + Google Play purchase flow on a real
device. Covers build-time keys, getting a testable build onto the device,
license testers, the E2E flow, and debugging.

- **App id:** `br.com.circulari.ai`
- **Paid tiers:** `essencial`, `pro` — each with a monthly and an annual plan
- **SDK:** `purchases_flutter` (RevenueCat)

---

## 1. Build-time keys (`--dart-define`)

The RevenueCat public SDK keys are injected at build time and read in
`lib/core/purchases/purchases_service.dart`:

```dart
static const _iosKey = String.fromEnvironment('REVENUECAT_IOS_KEY');
static const _androidKey = String.fromEnvironment('REVENUECAT_ANDROID_KEY');
```

If the key is missing, `PurchasesService.configure()` no-ops and **subscriptions
are silently disabled** (empty paywall). So every build/run you test with must
supply it.

Instead of pasting the key into every command, use a defines file:

```bash
cp dart_defines.example.json dart_defines.json   # then fill in the real keys
```

`dart_defines.json` is gitignored (it holds the real keys); the
`goog_…` / `appl_…` values come from **RevenueCat → Project → API keys**
(the *public* SDK keys — never the secret REST key).

Then pass it to any Flutter command:

```bash
flutter run          --dart-define-from-file=dart_defines.json
flutter build appbundle --release --dart-define-from-file=dart_defines.json
```

---

## 2. Prerequisites

Google Play billing only returns products when **all** of these hold:

1. The app has been uploaded to a Play track at least once, **signed with the
   release key** (debug-keystore builds can't make real purchases).
2. `applicationId` is exactly `br.com.circulari.ai`.
3. The subscription **base plans are Active** in Play Console (not Draft).
4. The test device's Google account is a **License tester**.
5. In RevenueCat: the **current offering** contains the packages, products are
   attached to the `essencial` / `pro` entitlements, and the Play **service
   credentials show green** — including *"Can validate Google Play subscription
   purchases"*. If that check is red, purchases fail at the RevenueCat layer
   even when Google succeeds.

---

## 3. Add license testers

**Play Console → Settings → License testing** → add the Google account(s) you
test with. License testers get Google's **test payment methods** (no real
charge) and **accelerated renewals** (see §6).

---

## 4. Get a testable build onto the device

Real purchases require a **release-signed** build installed **from Google**
(not `flutter run` of a debug build). Pick a path:

### A. Internal testing track (most reliable)

```bash
flutter build appbundle --release --dart-define-from-file=dart_defines.json
```

Upload the `.aab` to **Play Console → Testing → Internal testing → Create
release**, add testers, open the **opt-in URL** on the device, install from the
Play Store. Ready within minutes.

### B. Internal App Sharing (fastest iteration)

Uploads *any* release-signed build via a link — no track or review. Enable it
in Play Console, upload the `.aab`, open the share link on the device, install.
License testers can still make test purchases this way.

> `flutter run` (debug) cannot test real purchases: the debug signature won't
> match the uploaded app. Always build `--release` and install via A or B.

---

## 5. The E2E flow — verify every layer

Open the paywall and check the whole chain, not just the UI:

1. **Products load** — all four prices appear (essencial + pro, monthly +
   annual). Empty → missing key (§1) or offering not marked *current*.
2. **Purchase** — Google's *test card* sheet appears; complete it.
3. **Entitlement** — RevenueCat dashboard → **Customers** → find your
   `app_user_id` (the backend user id, bound by `PurchasesService.login`) →
   confirm the `pro` / `essencial` entitlement is active.
4. **Backend** — confirm the webhook flipped `users.tier` (what the app reads
   for gating).
5. **Restore** — reinstall or trigger restore → the entitlement returns.
6. **Cancel** — Play Store app → **Payments & subscriptions → Subscriptions** →
   cancel → confirm RevenueCat + backend reflect it after the (accelerated)
   expiry.

---

## 6. Renewal timing & re-testing

License-tester subscriptions renew on Google's **accelerated schedule** (monthly
≈ 5 min, auto-cancels after ~6 renewals; yearly ≈ 30 min). To test a clean
first purchase again: cancel and let it expire, or use a different tester
account.

---

## 7. Debugging

- **Verbose logs:** temporarily set `LogLevel.debug` in
  `purchases_service.dart` (`Purchases.setLogLevel`) to see every RevenueCat
  request/response. Revert before release.
- **Empty paywall** → missing `--dart-define` key, or offering not *current*.
- **"Item not available"** → base plan still Draft, or the account isn't a
  license tester.
- **Purchase succeeds but no entitlement** → product not attached to the
  entitlement, or the *validate purchases* credential check is red (§2.5).
