import 'package:flutter/material.dart';
import '../../core/theme/unified_theme.dart';

class Enhanced3DCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? margin;
  final EdgeInsets? padding;
  final BoxDecoration? decoration;
  final bool enable3D;
  final bool enableHover;
  final double elevationOnHover;
  final Duration animationDuration;

  const Enhanced3DCard({
    super.key,
    required this.child,
    this.onTap,
    this.margin,
    this.padding,
    this.decoration,
    this.enable3D = true,
    this.enableHover = true,
    this.elevationOnHover = 10,
    this.animationDuration = const Duration(milliseconds: 200),
  });

  @override
  State<Enhanced3DCard> createState() => _Enhanced3DCardState();
}

class _Enhanced3DCardState extends State<Enhanced3DCard>
    with TickerProviderStateMixin {
  late AnimationController _hoverController;
  late AnimationController _tapController;
  late Animation<double> _elevationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    
    _hoverController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _tapController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _elevationAnimation = Tween<double>(
      begin: 0,
      end: widget.elevationOnHover,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.02,
    ).animate(CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _tapController.dispose();
    super.dispose();
  }

  void _onHover(bool hovering) {
    if (!widget.enableHover) return;
    
    setState(() {
      _isHovered = hovering;
    });

    if (hovering) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  void _onTap() {
    _tapController.forward().then((_) {
      _tapController.reverse();
    });
    
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_hoverController, _tapController]),
      builder: (context, child) {
        return GestureDetector(
          onTap: widget.onTap != null ? _onTap : null,
          child: MouseRegion(
            onEnter: (_) => _onHover(true),
            onExit: (_) => _onHover(false),
            child: Transform.scale(
              scale: _scaleAnimation.value * (1.0 - _tapController.value * 0.05),
              child: widget.enable3D
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateX(_rotationAnimation.value)
                        ..rotateY(_rotationAnimation.value * 0.5),
                      child: _buildCard(),
                    )
                  : _buildCard(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard() {
    final defaultDecoration = BoxDecoration(
      color: UnifiedTheme.white,
      borderRadius: BorderRadius.circular(UnifiedTheme.radiusL),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1 + _elevationAnimation.value * 0.01),
          blurRadius: 10 + _elevationAnimation.value,
          offset: Offset(0, 5 + _elevationAnimation.value * 0.5),
        ),
      ],
    );

    return AnimatedContainer(
      duration: widget.animationDuration,
      margin: widget.margin,
      padding: widget.padding ?? const EdgeInsets.all(UnifiedTheme.spacingL),
      decoration: widget.decoration ?? defaultDecoration,
      child: widget.child,
    );
  }
}

class CategoryCard3D extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;

  const CategoryCard3D({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Enhanced3DCard(
      onTap: onTap,
      decoration: BoxDecoration(
        color: isSelected 
            ? UnifiedTheme.primary 
            : (backgroundColor ?? UnifiedTheme.white),
        borderRadius: BorderRadius.circular(15),
        boxShadow: isSelected 
            ? UnifiedTheme.primaryShadow 
            : UnifiedTheme.cardShadow,
      ),
      child: SizedBox(
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                icon,
                size: 30,
                color: isSelected 
                    ? Colors.white 
                    : (iconColor ?? UnifiedTheme.primary),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isSelected 
                    ? Colors.white 
                    : UnifiedTheme.primaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class PerformanceCard3D extends StatelessWidget {
  final String title;
  final String value;
  final String label;
  final Color color;
  final IconData? icon;
  final double? progress;

  const PerformanceCard3D({
    super.key,
    required this.title,
    required this.value,
    required this.label,
    required this.color,
    this.icon,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Enhanced3DCard(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
          ],
          Text(
            value,
            style: TextStyle(
              fontSize: progress != null ? 20 : 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: UnifiedTheme.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress! / 100,
                backgroundColor: Colors.grey.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '${progress!.toInt()}% Complete',
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class EbookCard3D extends StatelessWidget {
  final String title;
  final String author;
  final String price;
  final double rating;
  final LinearGradient? gradient;
  final String? coverImage;
  final String? badge;
  final VoidCallback? onTap;

  const EbookCard3D({
    super.key,
    required this.title,
    required this.author,
    required this.price,
    required this.rating,
    this.gradient,
    this.coverImage,
    this.badge,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Enhanced3DCard(
      onTap: onTap,
      margin: const EdgeInsets.only(right: 20),
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: UnifiedTheme.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: UnifiedTheme.cardShadow,
      ),
      child: SizedBox(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Cover
            Container(
              height: 140,
              decoration: BoxDecoration(
                gradient: coverImage == null ? (gradient ?? UnifiedTheme.primaryGradient) : null,
                image: coverImage != null ? DecorationImage(
                  image: AssetImage(coverImage!),
                  fit: BoxFit.cover,
                ) : null,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  // Shine effect
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.3),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.6],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (badge != null)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: UnifiedTheme.accent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Icon(
                      Icons.menu_book,
                      size: 60,
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
            // Book Info
            Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    author,
                    style: const TextStyle(
                      color: UnifiedTheme.secondaryText,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: UnifiedTheme.dark,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: UnifiedTheme.accent,
                            size: 14,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            rating.toString(),
                            style: const TextStyle(
                              color: UnifiedTheme.accent,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}