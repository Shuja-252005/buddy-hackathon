part of '../main.dart';

class _StatusBar extends StatelessWidget {
  const _StatusBar({required this.top});
  final double top;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.fromLTRB(29, top + 5, 25, 9),
    child: SizedBox(
      height: 37,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            '9:41',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Row(
            children: const [
              Icon(Icons.signal_cellular_alt, size: 15),
              SizedBox(width: 5),
              Icon(Icons.wifi, size: 16),
              SizedBox(width: 5),
              Icon(Icons.battery_full, size: 20),
            ],
          ),
        ],
      ),
    ),
  );
}
