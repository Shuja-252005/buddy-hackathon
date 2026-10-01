part of '../main.dart';

class _Mark extends StatelessWidget {
  const _Mark({this.small = false});
  final bool small;
  @override
  Widget build(BuildContext context) => Container(
    width: small ? 32 : 44,
    height: small ? 32 : 44,
    decoration: BoxDecoration(
      color: const Color(0xFF1B2535),
      border: Border.all(color: const Color(0xFF353E50)),
      borderRadius: BorderRadius.circular(11),
    ),
    child: CustomPaint(
      size: Size(small ? 17 : 23, small ? 17 : 23),
      painter: _BuddyMarkPainter(),
    ),
  );
}

class _BuddyMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24;
    final paint = Paint()
      ..color = const Color(0xFF8FB1FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final mark = Path()
      ..moveTo(5, 17.5)
      ..lineTo(12, 5)
      ..lineTo(19, 17.5)
      ..moveTo(8, 13.5)
      ..lineTo(16, 13.5);
    canvas.save();
    canvas.scale(scale);
    canvas.drawPath(mark, paint);
    canvas.drawCircle(
      const Offset(19, 17.5),
      1.8,
      Paint()..color = const Color(0xFF8FB1FF),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

extension on String {
  Color toColor() {
    final value = replaceFirst('#', '');
    return Color(int.parse('FF$value', radix: 16));
  }
}
