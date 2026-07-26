/// Aux spacing and radius tokens — Section 5.5 of the product spec.
/// 4px base unit. Scale: 4/8/12/16/24/32/48.
abstract final class AuxSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  // ── Corner radius ──────────────────────────────────────────────
  /// Cards, list tiles, track rows
  static const double radiusCard = 12;

  /// Bottom sheets, modals, dialogs
  static const double radiusSheet = 20;

  /// Avatars, play/pause FAB — fully circular, use with ShapeBorder
  static const double radiusCircular = 999;

  // ── Tap target minimum ─────────────────────────────────────────
  /// 48dp minimum per accessibility spec (§7)
  static const double minTapTarget = 48;

  // ── Bottom nav + mini-player ───────────────────────────────────
  /// Height of the persistent mini-player bar
  static const double miniPlayerHeight = 72;

  /// Height of the bottom navigation bar
  static const double bottomNavHeight = 64;

  // ── Album art sizes ────────────────────────────────────────────
  static const double artXs = 40;
  static const double artSm = 56;
  static const double artMd = 80;
  static const double artLg = 160;
  static const double artXl = 280;
}
