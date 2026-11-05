import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme.dart';

IconData chapterIcon(String key) {
  switch (key) {
    case 'chat': return Icons.record_voice_over;
    case 'scroll': return Icons.history_edu;
    case 'balance': return Icons.scale;
    case 'people': return Icons.groups;
    case 'books': return Icons.menu_book;
    case 'gavel': return Icons.gavel;
    case 'handshake': return Icons.compare_arrows;
    case 'witness': return Icons.person_pin;
    case 'shield': return Icons.shield;
    default: return Icons.balance;
  }
}

/// Compact label such as "3, 5-16" from section numbers (plain numbers form ranges).
String sectionRangeLabel(List<String> numbers) {
  final bases = <int>[];
  final suffixed = <String>[];
  for (final n in numbers) {
    final m = RegExp(r'^(\d+)([A-Z]*)$').firstMatch(n);
    if (m == null) continue;
    final b = int.parse(m.group(1)!);
    if (m.group(2)!.isEmpty) {
      bases.add(b);
    } else {
      suffixed.add(n);
    }
  }
  bases.sort();
  final parts = <String>[];
  var i = 0;
  while (i < bases.length) {
    var j = i;
    while (j + 1 < bases.length && bases[j + 1] == bases[j] + 1) { j++; }
    parts.add(j > i ? (j - i >= 1 ? '${bases[i]}-${bases[j]}' : '${bases[i]}') : '${bases[i]}');
    i = j + 1;
  }
  if (suffixed.isNotEmpty) parts.add(suffixed.length <= 3 ? suffixed.join(', ') : '+${suffixed.length} amended');
  return parts.join(', ');
}

class ProgressRing extends StatelessWidget {
  final double value;
  final String label;
  final double size;
  const ProgressRing({super.key, required this.value, required this.label, this.size = 76});
  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: Stack(alignment: Alignment.center, children: [
          CustomPaint(size: Size.square(size), painter: _RingPainter(value.clamp(0.0, 1.0))),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        ]),
      );
}

class _RingPainter extends CustomPainter {
  final double v;
  _RingPainter(this.v);
  @override
  void paint(Canvas c, Size s) {
    final r = Rect.fromLTWH(5, 5, s.width - 10, s.height - 10);
    final bg = Paint()..style = PaintingStyle.stroke..strokeWidth = 8..color = AppColors.navy2;
    final fg = Paint()..style = PaintingStyle.stroke..strokeWidth = 8..strokeCap = StrokeCap.round..color = AppColors.gold;
    c.drawArc(r, 0, math.pi * 2, false, bg);
    c.drawArc(r, -math.pi / 2, math.pi * 2 * v, false, fg);
  }
  @override
  bool shouldRepaint(_RingPainter o) => o.v != v;
}

class Bar extends StatelessWidget {
  final double value;
  final Color color, track;
  final double height;
  const Bar({super.key, required this.value, this.color = AppColors.gold, this.track = const Color(0x33000000), this.height = 8});
  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: LinearProgressIndicator(value: value.clamp(0.0, 1.0), minHeight: height, color: color, backgroundColor: track),
      );
}

class XpChip extends StatelessWidget {
  final int xp;
  final Color color;
  const XpChip(this.xp, {super.key, this.color = AppColors.gold});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.emoji_events, size: 20, color: color),
        const SizedBox(width: 4),
        Text('$xp XP', style: TextStyle(fontWeight: FontWeight.w800, color: color)),
      ]);
}

class Panel extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsets padding;
  final Color? border;
  const Panel({super.key, required this.child, this.color, this.padding = const EdgeInsets.all(16), this.border});
  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color ?? AppColors.navy2,
          borderRadius: BorderRadius.circular(18),
          border: border == null ? null : Border.all(color: border!, width: 1.2),
          boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 10, offset: Offset(0, 4))],
        ),
        child: child,
      );
}

void toast(BuildContext c, String m) =>
    ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(m), duration: const Duration(seconds: 2)));
