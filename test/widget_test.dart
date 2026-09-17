import 'package:flutter_test/flutter_test.dart';
import 'package:smartflow/presentation/widgets/mascot_art.dart';
import 'package:smartflow/presentation/widgets/neo_badge.dart';
import 'package:smartflow/presentation/widgets/neo_card.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Neo-Brutalist widgets and Crab Mascot render properly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              CrabMascotWidget(mood: MascotMood.happy, size: 80),
              NeoCard(child: Text('Test Card')),
              NeoBadge(text: 'Uang Hilang'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Test Card'), findsOneWidget);
    expect(find.text('Uang Hilang'), findsOneWidget);
    expect(find.byType(CrabMascotWidget), findsOneWidget);
  });
}
