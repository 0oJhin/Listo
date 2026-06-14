import 'package:flutter_test/flutter_test.dart';
import 'package:listomobile/main.dart';

void main() {
  testWidgets('exibe campos de login por email e senha', (tester) async {
    await tester.pumpWidget(const ListoApp());

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Senha'), findsOneWidget);
    expect(find.textContaining('ID'), findsNothing);
  });
}
