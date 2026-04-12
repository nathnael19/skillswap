import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionItem extends StatelessWidget {
  final Map<String, dynamic> data;

  const TransactionItem({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFFCA8A04);
    
    final String type = data['type'] ?? 'earn';
    final bool isPositive = type == 'earn';
    final String title = data['description'] ?? (isPositive ? 'Revenue Inflow' : 'Credit Expenditure');
    final String amount = (data['amount'] ?? 0).toString();
    final String rawTimestamp = data['timestamp'] ?? '';
    final String subtitle = _formatSubtitle(rawTimestamp);

    IconData icon;
    if (type == 'earn') {
      icon = Icons.add_chart_rounded;
    } else if (type == 'spend') {
      icon = Icons.shopping_basket_rounded;
    } else {
      icon = Icons.auto_awesome_rounded;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPositive 
                ? accentColor.withValues(alpha: 0.1) 
                : Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              border: Border.all(
                color: isPositive 
                  ? accentColor.withValues(alpha: 0.2) 
                  : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Icon(
              icon, 
              color: isPositive ? accentColor : Colors.white.withValues(alpha: 0.5), 
              size: 20
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.3),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isPositive ? '+$amount' : '-$amount',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: isPositive ? accentColor : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _formatSubtitle(String rawTimestamp) {
    if (rawTimestamp.isEmpty) return 'Recent History';
    try {
      final dateTime = DateTime.parse(rawTimestamp).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
      if (difference.inHours < 24) return '${difference.inHours}h ago';
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'Completed Item';
    }
  }
}
