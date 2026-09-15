import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_first_app/main.dart';

void main() {
  testWidgets('Operasi tambah menghasilkan hasil yang benar',
      (WidgetTester tester) async {
    await tester.pumpWidget(const KalkulatorKabatakuApp());

    await tester.enterText(find.byType(TextFormField).at(0), '12');
    await tester.enterText(find.byType(TextFormField).at(1), '30');

    await tester.ensureVisible(find.text('Tambah'));
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    expect(find.text('42'), findsOneWidget);
    expect(find.text('12 + 30'), findsOneWidget);
  });

  testWidgets('Operasi bagi menghasilkan hasil yang benar',
      (WidgetTester tester) async {
    await tester.pumpWidget(const KalkulatorKabatakuApp());

    await tester.enterText(find.byType(TextFormField).at(0), '10');
    await tester.enterText(find.byType(TextFormField).at(1), '4');

    await tester.ensureVisible(find.text('Bagi'));
    await tester.tap(find.text('Bagi'));
    await tester.pumpAndSettle();

    expect(find.text('2.5'), findsOneWidget);
  });

  testWidgets('Validasi muncul saat input kosong', (WidgetTester tester) async {
    await tester.pumpWidget(const KalkulatorKabatakuApp());

    await tester.ensureVisible(find.text('Tambah'));
    await tester.tap(find.text('Tambah'));
    await tester.pumpAndSettle();

    expect(find.text('Angka tidak boleh kosong'), findsNWidgets(2));
  });
}
