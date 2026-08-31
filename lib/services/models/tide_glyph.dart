/// The abstract shape vocabulary.
///
/// Tide deliberately avoids pictographic icons — a glass for water, a book
/// for reading — because the app is about rhythm rather than subject matter.
/// Every glyph is a simple geometric form drawn by `HabitGlyphPainter`, so
/// the icon set reads as one instrument panel instead of a sticker sheet.
enum TideGlyph {
  crescent,
  lines,
  peak,
  halfMoon,
  diamond,
  square,
  diamondOutline,
  dot,
  striped,
  hexagon,
  sparkle,
  ring;

  /// The seven offered in the add/edit icon picker, in prototype order.
  static const List<TideGlyph> pickable = [
    TideGlyph.crescent,
    TideGlyph.lines,
    TideGlyph.peak,
    TideGlyph.halfMoon,
    TideGlyph.diamond,
    TideGlyph.square,
    TideGlyph.diamondOutline,
  ];
}
