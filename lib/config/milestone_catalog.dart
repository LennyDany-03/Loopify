import '../services/models/milestone.dart';
import '../services/models/tide_glyph.dart';

/// The nine badges, ordered by how hard they are to reach.
///
/// Names stay inside the tidal metaphor — a spring tide, a full moon, deep
/// water — so the reward vocabulary matches the rest of the product rather
/// than reading as generic gamification.
abstract final class MilestoneCatalog {
  static const List<Milestone> all = [
    Milestone(
      id: 'first-tide',
      name: 'First tide',
      glyph: TideGlyph.dot,
      threshold: 1,
      caption: '1 day',
    ),
    Milestone(
      id: 'one-week',
      name: 'One week',
      glyph: TideGlyph.crescent,
      threshold: 7,
      caption: '7 days',
    ),
    Milestone(
      id: 'fortnight',
      name: 'Fortnight',
      glyph: TideGlyph.diamond,
      threshold: 14,
      caption: '14 days',
    ),
    Milestone(
      id: 'full-moon',
      name: 'Full moon',
      glyph: TideGlyph.striped,
      threshold: 30,
      caption: '30 days',
    ),
    Milestone(
      id: 'spring-tide',
      name: 'Spring tide',
      glyph: TideGlyph.diamondOutline,
      threshold: 60,
      caption: '60 days',
    ),
    Milestone(
      id: 'hundred',
      name: 'Hundred',
      glyph: TideGlyph.sparkle,
      threshold: 100,
      caption: '100 days',
    ),
    Milestone(
      id: 'six-months',
      name: 'Six months',
      glyph: TideGlyph.ring,
      threshold: 180,
      caption: '180 days',
    ),
    Milestone(
      id: 'deep-water',
      name: 'Deep water',
      glyph: TideGlyph.hexagon,
      threshold: 365,
      caption: '365 days',
    ),
    Milestone(
      id: 'no-freezes',
      name: 'No freezes',
      glyph: TideGlyph.halfMoon,
      threshold: 90,
      caption: '90 clean',
      kind: MilestoneKind.cleanDays,
    ),
  ];
}
