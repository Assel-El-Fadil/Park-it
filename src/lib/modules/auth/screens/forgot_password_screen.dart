import 'package:flutter/material.dart';
import 'package:src/core/config/themes/app_theme.dart';
import 'package:src/core/config/themes/color_palette.dart';
import 'package:src/core/config/themes/text_styles.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price with Airbnb's price style
          Text('\$199', style: AppTextStyles.priceLarge),

          // Rating with star
          Row(
            children: [
              Icon(Icons.star, color: context.colorScheme.tertiary, size: 16),
              const SizedBox(width: 4),
              Text('4.95', style: AppTextStyles.rating),
            ],
          ),

          // Superhost badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.superhost,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'SUPERHOST',
              style: AppTextStyles.superhost.copyWith(color: Colors.white),
            ),
          ),

          // Description with theme-aware colors
          Text(
            'Beautiful beachfront villa',
            style: context.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
