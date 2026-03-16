import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark theme required
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Color/Image Overlay Effect
          Container(color: Colors.black.withOpacity(0.8)),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Navigation Bar - Logo Only
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 24.0,
                  ),
                  child: Text(
                    'parkit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),

                // Centered Hero Content
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              'PARKING JUST GOT A LOT SIMPLER',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Book the Best Spaces & Save Up to 50%',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontStyle: FontStyle.italic,
                                fontFamily:
                                    'Georgia', // Serif-like text for subtitle
                              ),
                            ),
                            const SizedBox(height: 48),

                            // No tabs as requested

                            // Search Bar Row
                            Container(
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFE8ECEF,
                                ), // Light grayish-blue from screenshot
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                    ),
                                    child: Icon(
                                      Icons.location_on,
                                      color: Color(
                                        0xFFFF5A5F,
                                      ), // Coral red from screenshot
                                      size: 28,
                                    ),
                                  ),
                                  const Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText:
                                            'Search Address, Place or Event',
                                        hintStyle: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 16,
                                        ),
                                        border: InputBorder.none,
                                        filled: false,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 60,
                                    decoration: const BoxDecoration(
                                      color: Color(
                                        0xFFF04B5A,
                                      ), // More accurate red from the image
                                      borderRadius: BorderRadius.horizontal(
                                        right: Radius.circular(4),
                                      ),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {},
                                        borderRadius:
                                            const BorderRadius.horizontal(
                                              right: Radius.circular(4),
                                            ),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 24.0,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'FIND PARKING',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Icon(
                                                Icons.search,
                                                color: Colors.white,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
