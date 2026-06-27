import '../models/meal_detail.dart';

class MealDetailRepository {
  const MealDetailRepository();

  static final Map<String, MealDetail> _details = {
    '親子丼': const MealDetail(
      name: '親子丼',
      time: '20分',
      category: '主菜',
      ingredients: ['鶏もも肉 200g', '卵 2個', '玉ねぎ 1/2個', 'めんつゆ 大さじ3', 'ご飯 2人分'],
      steps: [
        '玉ねぎを薄切りにする',
        '鶏肉を一口サイズに切る',
        'フライパンで具材を煮る',
        '溶き卵を入れて半熟で止める',
        'ご飯にのせる',
      ],
      comment: '時短で作れて、子どもにも人気の献立です。',
    ),
    'カレーライス': const MealDetail(
      name: 'カレーライス',
      time: '35分',
      category: '主菜',
      ingredients: ['豚肉 200g', '玉ねぎ 1個', 'にんじん 1本', 'じゃがいも 2個', 'カレールー 適量'],
      steps: ['野菜を一口サイズに切る', '肉と野菜を炒める', '水を入れて煮込む', 'ルーを入れてさらに煮る', 'ご飯にかける'],
      comment: '作り置きにも向いていて、翌日も使いやすい献立です。',
    ),
    '焼きそば': const MealDetail(
      name: '焼きそば',
      time: '15分',
      category: '主菜',
      ingredients: ['焼きそば麺 2玉', '豚こま肉 150g', 'キャベツ 1/4個', 'もやし 1袋', 'ソース 適量'],
      steps: ['野菜を切る', '肉を炒める', '野菜と麺を入れる', 'ソースで味付けする'],
      comment: '忙しい日にかなり使いやすい時短メニューです。',
    ),
    'ハンバーグ': const MealDetail(
      name: 'ハンバーグ',
      time: '30分',
      category: '主菜',
      ingredients: ['合いびき肉 300g', '玉ねぎ 1/2個', '卵 1個', 'パン粉 大さじ4', '牛乳 大さじ3'],
      steps: ['玉ねぎをみじん切りにする', '材料をボウルで混ぜる', '形を整える', 'フライパンで両面を焼く', 'ふたをして中まで火を通す'],
      comment: '家族みんなで食べやすい定番メニューです。',
    ),
    'オムライス': const MealDetail(
      name: 'オムライス',
      time: '25分',
      category: '主菜',
      ingredients: ['ご飯 2人分', '卵 3個', '鶏肉 150g', '玉ねぎ 1/2個', 'ケチャップ 大さじ4'],
      steps: ['玉ねぎと鶏肉を切る', '具材を炒める', 'ご飯とケチャップを入れて炒める', '卵を焼く', 'チキンライスに卵をのせる'],
      comment: '子どもにも人気で、休日ランチにも使いやすい献立です。',
    ),
    '豚の生姜焼き': const MealDetail(
      name: '豚の生姜焼き',
      time: '25分',
      category: '主菜',
      ingredients: ['豚ロース肉 250g', '玉ねぎ 1/2個', 'しょうがチューブ 小さじ2', 'しょうゆ 大さじ2', 'みりん 大さじ2'],
      steps: ['玉ねぎを薄切りにする', '調味料を混ぜる', '豚肉と玉ねぎを焼く', '調味料を入れて絡める', '皿に盛り付ける'],
      comment: 'ご飯が進む定番おかずで、忙しい日にも作りやすいです。',
    ),
    '鮭のホイル焼き': const MealDetail(
      name: '鮭のホイル焼き',
      time: '25分',
      category: '主菜',
      ingredients: ['鮭 2切れ', 'しめじ 1/2株', '玉ねぎ 1/2個', 'バター 10g', 'ポン酢 適量'],
      steps: ['野菜を薄切りにする', 'アルミホイルに鮭と野菜をのせる', 'バターをのせて包む', 'フライパンで蒸し焼きにする'],
      comment: '栄養バランスを整えやすく、洗い物も少なめです。',
    ),
    'ビビンバ': const MealDetail(
      name: 'ビビンバ',
      time: '30分',
      category: '主菜',
      ingredients: ['ご飯 2人分', '牛こま肉 150g', 'にんじん 1/2本', 'ほうれん草 1束', '卵 2個'],
      steps: ['野菜をゆでて味付けする', '牛肉を炒める', '目玉焼きを作る', 'ご飯に具材をのせる'],
      comment: '野菜をしっかり取れて、いつもと違う食卓にしやすい献立です。',
    ),
    '生姜焼き': const MealDetail(
      name: '生姜焼き',
      time: '25分',
      category: '主菜',
      ingredients: ['豚ロース肉 250g', '玉ねぎ 1/2個', 'しょうが 小さじ2', 'しょうゆ 大さじ2', 'みりん 大さじ2'],
      steps: ['調味料を合わせる', '豚肉と玉ねぎを焼く', '調味料を加えて絡める'],
      comment: '手早く作れて満足感も出しやすい献立です。',
    ),
    '麻婆豆腐': const MealDetail(
      name: '麻婆豆腐',
      time: '20分',
      category: '主菜',
      ingredients: ['豆腐 1丁', '豚ひき肉 150g', '長ねぎ 1/2本', '麻婆豆腐の素 適量'],
      steps: ['長ねぎを刻む', 'ひき肉を炒める', '豆腐と調味料を加えて煮る'],
      comment: '短時間で作れて、主菜として満足感があります。',
    ),
    'サバの味噌煮': const MealDetail(
      name: 'サバの味噌煮',
      time: '30分',
      category: '主菜',
      ingredients: ['サバ 2切れ', 'しょうが 1かけ', '味噌 大さじ2', 'みりん 大さじ2', '砂糖 大さじ1'],
      steps: ['煮汁を作る', 'サバとしょうがを入れる', '落としぶたをして煮る'],
      comment: '魚を取り入れたい日に使いやすい和食メニューです。',
    ),
    '冷やし中華': const MealDetail(
      name: '冷やし中華',
      time: '15分',
      category: '主菜',
      ingredients: ['中華麺 2玉', '卵 2個', 'きゅうり 1本', 'ハム 4枚', 'たれ 適量'],
      steps: ['麺をゆでて冷やす', '具材を細切りにする', '麺に具材をのせてたれをかける'],
      comment: '暑い日や短時間で済ませたい日に向いています。',
    ),
  };

  MealDetail findByName(String name, {String category = '献立'}) {
    return _details[name] ??
        MealDetail(
          name: name,
          time: category == '汁物' ? '10分' : '15分',
          category: category,
          ingredients: _fallbackIngredients(category),
          steps: _fallbackSteps(category),
          comment: '$categoryとして組み合わせやすい一品です。主菜とのバランスを見て量を調整してください。',
        );
  }

  List<String> _fallbackIngredients(String category) {
    if (category == '汁物') {
      return ['だし 400ml', '好みの具材 適量', '味噌または塩 適量'];
    }

    if (category == '副菜') {
      return ['野菜 適量', '調味料 適量', 'ごままたはかつお節 少々'];
    }

    return ['主な食材 適量', '調味料 適量'];
  }

  List<String> _fallbackSteps(String category) {
    if (category == '汁物') {
      return ['具材を食べやすく切る', 'だしで具材を煮る', '味を整える'];
    }

    if (category == '副菜') {
      return ['食材を下ごしらえする', '調味料で和える', '器に盛り付ける'];
    }

    return ['食材を下ごしらえする', '火を通す', '味を整えて盛り付ける'];
  }
}
