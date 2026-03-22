import 'package:flutter/material.dart';

class PhotoCarousel extends StatefulWidget {
  const PhotoCarousel({super.key, required this.photos, this.aspectRatio = 16 / 9});

  final List<String> photos;
  final double aspectRatio;

  @override
  State<PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<PhotoCarousel> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (widget.photos.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: Container(
            color: theme.colorScheme.surfaceContainerHighest,
            child: const Center(
              child: Icon(Icons.local_parking, size: 40),
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: AspectRatio(
        aspectRatio: widget.aspectRatio,
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.photos.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                return Image.network(
                  widget.photos[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Icon(Icons.error_outline),
                  ),
                );
              },
            ),
            if (widget.photos.length > 1) ...[
              // Dot Indicators
              Positioned(
                bottom: 12,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.photos.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentIndex == index
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ),
              // Navigation Buttons
              Positioned(
                left: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _NavButton(
                    icon: Icons.chevron_left,
                    onPressed: _currentIndex > 0
                        ? () => _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            )
                        : null,
                  ),
                ),
              ),
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: _NavButton(
                    icon: Icons.chevron_right,
                    onPressed: _currentIndex < widget.photos.length - 1
                        ? () => _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            )
                        : null,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.3),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.all(4),
      ),
    );
  }
}
