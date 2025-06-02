import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(subtitle, style: TextStyle(fontSize: 16, color: Colors.grey[600])),
      ],
    );
  }
}

class AuthHeaderWithBackground extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? logoPath;
  final double logoSize;
  final Color? backgroundColor;
  final Color? textColor;

  const AuthHeaderWithBackground({
    super.key,
    required this.title,
    required this.subtitle,
    this.logoPath,
    this.logoSize = 80,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Theme.of(context).primaryColor;
    final txtColor = textColor ?? Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Logo
          Container(
            width: logoSize,
            height: logoSize,
            decoration: BoxDecoration(
              color: txtColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child:
                logoPath != null
                    ? ClipOval(
                      child: Image.asset(
                        logoPath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultLogo(txtColor);
                        },
                      ),
                    )
                    : _buildDefaultLogo(txtColor),
          ),

          const SizedBox(height: 24),

          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: txtColor,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Subtitle
          Text(
            subtitle,
            style: TextStyle(fontSize: 16, color: txtColor.withOpacity(0.9)),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Institution name
          Text(
            'Liceo Industrial Chileno-Alemán de Frutillar',
            style: TextStyle(
              fontSize: 12,
              color: txtColor.withOpacity(0.8),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultLogo(Color color) {
    return Icon(Icons.school, size: logoSize * 0.5, color: color);
  }
}
