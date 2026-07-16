import 'package:flutter/material.dart';
import 'package:rmss/core/constants/app_colors.dart';

class InventoryCard extends StatelessWidget {
  final String name;
  final String category;
  final double price;
  final String imageUrl;
  final bool available;
  final VoidCallback onToggle;

  const InventoryCard({
    super.key,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.available,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: available ? AppColors.cocoaBrownDark : const Color(0xFF8A0012),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: available ? Colors.white10 : Colors.white12,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
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
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    width: 65,
                    height: 65,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) {
                      return Container(
                        width: 65,
                        height: 65,
                        color: Colors.grey.shade800,
                        child: const Icon(
                          Icons.fastfood,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentOrange.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        category.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.lightText,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                "\$${price.toStringAsFixed(2)}",
                style: const TextStyle(
                  color: AppColors.accentOrange,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const Spacer(),

          Row(
            children: [
              const Text(
                "STATUS",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: available ? AppColors.accentOrange.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      available ? Icons.check_circle : Icons.remove_circle_outline,
                      size: 14,
                      color: available ? AppColors.accentOrange : Colors.white70,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      available ? "In Stock" : "Sold Out",
                      style: TextStyle(
                        color: available ? AppColors.accentOrange : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Align(
            alignment: Alignment.centerRight,
            child: Switch(
              value: available,
              activeThumbColor: AppColors.accentOrange,
              activeTrackColor: AppColors.accentOrange.withValues(alpha: 0.35),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.white24,
              onChanged: (_) => onToggle(),
            ),
          ),
        ],
      ),
    );
  }
}