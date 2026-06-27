import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kondate_ai/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ホームで保存したお気に入りをマイページで表示して削除できる', (tester) async {
    await tester.pumpWidget(const KondateAI());
    await tester.pumpAndSettle();

    expect(find.text('お気に入り保存'), findsOneWidget);

    await tester.tap(find.text('お気に入り保存'));
    await tester.pumpAndSettle();

    expect(find.text('お気に入り済み'), findsOneWidget);

    await tester.tap(find.text('マイページ'));
    await tester.pumpAndSettle();

    expect(find.text('お気に入り献立'), findsOneWidget);
    expect(find.text('親子丼'), findsOneWidget);
    expect(find.byIcon(Icons.delete), findsOneWidget);

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    expect(find.text('まだお気に入りはありません'), findsOneWidget);

    await tester.tap(find.text('ホーム'));
    await tester.pumpAndSettle();

    expect(find.text('お気に入り保存'), findsOneWidget);
  });

  testWidgets('お気に入りはアプリ再起動後も保持される', (tester) async {
    await tester.pumpWidget(const KondateAI());
    await tester.pumpAndSettle();

    await tester.tap(find.text('お気に入り保存'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    await tester.pumpWidget(const KondateAI());
    await tester.pumpAndSettle();

    expect(find.text('お気に入り済み'), findsOneWidget);

    await tester.tap(find.text('マイページ'));
    await tester.pumpAndSettle();

    expect(find.text('親子丼'), findsOneWidget);
  });
}
