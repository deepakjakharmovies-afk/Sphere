import 'package:flutter/material.dart';
import 'dart:math';

// Data model for the cards (same as before)
class Trip {
  final String title;
  final String subtitle;
  final Color color;

  Trip(this.title, this.subtitle, this.color);
}

// Example Data (same as before)
final List<Trip> trips = [
  Trip('Nice', 'France', Colors.lightBlue),
  Trip('Santorini', 'Greece', Colors.purple),
  Trip('Marrakech', 'Morocco', Colors.brown),
  Trip('Venezia', 'Italy', Colors.teal),
  Trip('North Central Province', 'Maldives', Colors.green),
  Trip('Rincon', 'Puerto Rico', Colors.blueGrey),
  Trip('Paris', 'France', Colors.pink),
  Trip('Bali', 'Indonesia', Colors.orange),
];

// --- 1. Transformer Function ---
/// Builds the transformation matrix without rotation (tilt).
Matrix4 buildScalePerspectiveMatrix({
  required double itemCenter,
  required double viewportCenter,
  required double cardHeight,
}) {
  // Distance from the center of the viewport (positive above, negative below)
  final double distanceFromCenter = itemCenter - viewportCenter;
  
  // Normalize distance for calculating scale
  final double normalizedDistance = (distanceFromCenter / cardHeight).clamp(-1.0, 1.0);

  // Scale factor: Smaller farther from the center (min scale 0.8)
  final double scale = 1.0 - (normalizedDistance.abs() * 0.2); 

  // Perspective factor (m34)
  final double perspectiveFactor = -0.001; 

  // 1. Start with an identity matrix
  final Matrix4 matrix = Matrix4.identity();

  // 2. Apply perspective transformation (key to the 3D look)
  // The perspectiveFactor in the m34 position creates the depth illusion.
  matrix.setEntry(3, 2, perspectiveFactor); 

  // 3. Apply uniform scale
  matrix.scale(scale, scale);

  // NOTE: We do NOT apply rotateX here, removing the tilt effect.

  return matrix;
}

// --- 2. Card Widget with Transformer applied ---
class CardTransformer extends StatelessWidget {
  final Trip trip;
  final double itemCenter;
  final double viewportCenter;
  final double cardHeight;

  const CardTransformer({
    required this.trip,
    required this.itemCenter,
    required this.viewportCenter,
    required this.cardHeight,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Call the function to get the transform matrix
    final Matrix4 transform = buildScalePerspectiveMatrix(
      itemCenter: itemCenter,
      viewportCenter: viewportCenter,
      cardHeight: cardHeight,
    );

    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed('/gridview');
        print('Card tapped: ${trip.title}');
      },
      child: Center(
        child: Transform(
          transform: transform,
          alignment: Alignment.topCenter,
          
          child: Card(
            elevation: 10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            color: trip.color,
            child: Container(
              height: cardHeight,
              width: MediaQuery.of(context).size.width * 0.9,
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    trip.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    trip.subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- 3. Main State Management Widget ---
class NoTiltCardList extends StatefulWidget {
  const NoTiltCardList({super.key});

  @override
  State<NoTiltCardList> createState() => _NoTiltCardListState();
}

class _NoTiltCardListState extends State<NoTiltCardList> {
  final _scrollController = ScrollController();
  final double _cardHeight = 150.0;
  final double _cardSpacing = 5.0;
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the center of the viewport
    final double viewportCenter = MediaQuery.of(context).size.height / 2;
    final double itemExtent = _cardHeight + _cardSpacing;

    return Scaffold(
      appBar: AppBar(title: const Text('Scale & Perspective List')),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: trips.length,
        itemExtent: itemExtent, 
        // Padding allows the first and last cards to reach the center
        // padding: EdgeInsets.symmetric(vertical: viewportCenter - (_cardHeight / 2)),
        
        itemBuilder: (context, index) {
          // Calculate the center position of the current item relative to the viewport top
          final double itemCenter = (index * itemExtent) - _scrollOffset + (_cardHeight / 2);

          return CardTransformer(
            trip: trips[index],
            itemCenter: itemCenter,
            viewportCenter: viewportCenter,
            cardHeight: _cardHeight,
          );
        },
      ),
    );
  }
}