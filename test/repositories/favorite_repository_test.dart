import 'package:flutter_test/flutter_test.dart';
import 'package:kondate_ai/repositories/favorite_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const repository = FavoriteRepository();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('お気に入りを保存して読み込める', () async {
    await repository.addFavorite('親子丼');

    final favorites = await repository.loadFavorites();

    expect(favorites, ['親子丼']);
  });

  test('同じ献立は重複保存しない', () async {
    await repository.addFavorite('親子丼');
    await repository.addFavorite('親子丼');

    final favorites = await repository.loadFavorites();

    expect(favorites, ['親子丼']);
  });

  test('保存済みのお気に入りを削除できる', () async {
    await repository.addFavorite('親子丼');
    await repository.addFavorite('カレーライス');

    await repository.removeFavorite('親子丼');

    final favorites = await repository.loadFavorites();

    expect(favorites, ['カレーライス']);
  });
}
