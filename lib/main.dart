import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/recipes.dart';
import 'models/recipe.dart';
import 'services/menu_generator.dart';

void main() {
  runApp(const KondateAI());
}

class KondateAI extends StatelessWidget {
  const KondateAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KONDATE AI',
      theme: ThemeData(colorSchemeSeed: Colors.orange, useMaterial3: true),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;
  @override
  void initState() {
    super.initState();

    loadFavorites();
    loadHistory();
    loadPriorities();
  }

  String favoriteMenu = '';
  bool isFavorite = false;

  List<String> historyMenus = [];

  List<String> favoriteMenus = [];
  double nutritionPriority = 40;
  double quickPriority = 20;
  double easyPriority = 20;
  double newPriority = 20;
  Widget prioritySlider(
    String title,
    double value,
    Function(double) onChanged,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$title ${value.toInt()}%'),
            Slider(
              value: value,
              min: 0,
              max: 100,
              divisions: 20,
              label: value.toInt().toString(),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  void toggleFavorite(String menu) {
    setState(() {
      if (favoriteMenus.contains(menu)) {
        favoriteMenus.remove(menu);
      } else {
        favoriteMenus.add(menu);
      }
    });

    saveFavorites();
  }

  void removeFavorite(String menu) {
    setState(() {
      favoriteMenus.remove(menu);
    });

    saveFavorites();
  }

  void updatePriorities({
    required double nutritionPriority,
    required double quickPriority,
    required double easyPriority,
    required double newPriority,
  }) {
    setState(() {
      this.nutritionPriority = nutritionPriority;
      this.quickPriority = quickPriority;
      this.easyPriority = easyPriority;
      this.newPriority = newPriority;
    });

    savePriorities();
  }

  Future<void> savePriorities() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble('nutritionPriority', nutritionPriority);
    await prefs.setDouble('quickPriority', quickPriority);
    await prefs.setDouble('easyPriority', easyPriority);
    await prefs.setDouble('newPriority', newPriority);
  }

  Future<void> loadPriorities() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      nutritionPriority = prefs.getDouble('nutritionPriority') ?? 40;

      quickPriority = prefs.getDouble('quickPriority') ?? 20;

      easyPriority = prefs.getDouble('easyPriority') ?? 20;

      newPriority = prefs.getDouble('newPriority') ?? 20;
    });
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFavorites = prefs.getStringList('favorites') ?? [];

    setState(() {
      favoriteMenus = savedFavorites;
    });
  }

  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorites', favoriteMenus);
  }

  Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('history', historyMenus);
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final savedHistory = prefs.getStringList('history') ?? [];

    setState(() {
      historyMenus = savedHistory;
    });
  }

  void addHistory(String menu) {
    setState(() {
      historyMenus.insert(0, menu);
    });

    saveHistory();
  }

  List<Widget> get pages => [
    HomePage(
      nutritionPriority: nutritionPriority,
      quickPriority: quickPriority,
      easyPriority: easyPriority,
      newPriority: newPriority,
      onFavorite: toggleFavorite,
      onHistory: addHistory,
    ),
    WeeklyPlanPage(),
    HistoryPage(historyMenus: historyMenus),
    MyPage(
      favoriteMenus: favoriteMenus,
      nutritionPriority: nutritionPriority,
      quickPriority: quickPriority,
      easyPriority: easyPriority,
      newPriority: newPriority,
      onRemoveFavorite: removeFavorite,
      onPrioritiesChanged: updatePriorities,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'ホーム'),
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: '週間献立',
          ),
          NavigationDestination(icon: Icon(Icons.history), label: '履歴'),
          NavigationDestination(icon: Icon(Icons.person), label: 'マイページ'),
        ],
      ),
    );
  }
}

Map<String, dynamic> getMealData(String menu) {
  final data = {
    '親子丼': {
      'time': '20分',
      'ingredients': ['鶏もも肉 200g', '卵 2個', '玉ねぎ 1/2個', 'めんつゆ 大さじ3', 'ご飯 2人分'],
      'steps': [
        '玉ねぎを薄切りにする',
        '鶏肉を一口サイズに切る',
        'フライパンで具材を煮る',
        '溶き卵を入れて半熟で止める',
        'ご飯にのせる',
      ],

      'comment': '時短で作れて、子どもにも人気の献立です😊',
    },
    'カレーライス': {
      'time': '35分',
      'ingredients': ['豚肉 200g', '玉ねぎ 1個', 'にんじん 1本', 'じゃがいも 2個', 'カレールー 適量'],
      'steps': ['野菜を一口サイズに切る', '肉と野菜を炒める', '水を入れて煮込む', 'ルーを入れてさらに煮る', 'ご飯にかける'],
      'comment': '作り置きにも向いていて、翌日も使いやすい献立です🍛',
    },
    '焼きそば': {
      'time': '15分',
      'ingredients': ['焼きそば麺 2玉', '豚こま肉 150g', 'キャベツ 1/4個', 'もやし 1袋', 'ソース 適量'],
      'steps': ['野菜を切る', '肉を炒める', '野菜と麺を入れる', 'ソースで味付けする'],
      'comment': '忙しい日にかなり使いやすい時短メニューです🔥',
    },
    'ハンバーグ': {
      'time': '30分',
      'ingredients': ['合いびき肉 300g', '玉ねぎ 1/2個', '卵 1個', 'パン粉 大さじ4', '牛乳 大さじ3'],
      'steps': [
        '玉ねぎをみじん切りにする',
        '材料をボウルで混ぜる',
        '形を整える',
        'フライパンで両面を焼く',
        'ふたをして中まで火を通す',
      ],
      'comment': '家族みんなで食べやすい定番メニューです🍖',
    },

    'オムライス': {
      'time': '25分',
      'ingredients': ['ご飯 2人分', '卵 3個', '鶏肉 150g', '玉ねぎ 1/2個', 'ケチャップ 大さじ4'],
      'steps': [
        '玉ねぎと鶏肉を切る',
        '具材を炒める',
        'ご飯とケチャップを入れて炒める',
        '卵を焼く',
        'チキンライスに卵をのせる',
      ],
      'comment': '子どもにも人気で、休日ランチにも使いやすい献立です🍳',
    },

    '豚の生姜焼き': {
      'time': '25分',
      'ingredients': [
        '豚ロース肉 250g',
        '玉ねぎ 1/2個',
        'しょうがチューブ 小さじ2',
        'しょうゆ 大さじ2',
        'みりん 大さじ2',
      ],
      'steps': ['玉ねぎを薄切りにする', '調味料を混ぜる', '豚肉と玉ねぎを焼く', '調味料を入れて絡める', '皿に盛り付ける'],
      'comment': 'ご飯が進む定番おかずで、忙しい日にも作りやすいです🔥',
    },
  };

  return data[menu] ??
      {
        'time': '30分',
        'ingredients': ['サンプル食材'],
        'steps': ['サンプル手順'],
        'comment': '今日はおすすめの献立です！',
      };
}

class MealDetailPage extends StatelessWidget {
  final String menu;
  final Function(String)? onFavorite;

  const MealDetailPage({super.key, required this.menu, this.onFavorite});

  @override
  Widget build(BuildContext context) {
    final mealData = getMealData(menu);
    final ingredients = mealData['ingredients'] as List<String>;
    final steps = mealData['steps'] as List<String>;

    return Scaffold(
      appBar: AppBar(
        title: Text(menu),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              onFavorite?.call(menu);

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('$menu をお気に入りに追加しました！')));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              menu,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            const Text('⏱️ 調理時間：30分', style: TextStyle(fontSize: 18)),

            const SizedBox(height: 20),

            Text('🛒 材料\n${ingredients.map((item) => '・$item').join('\n')}'),
            const SizedBox(height: 20),

            Text(
              '👨‍🍳 作り方\n${steps.asMap().entries.map((entry) => '${entry.key + 1}. ${entry.value}').join('\n')}',
            ),

            const SizedBox(height: 20),

            Text('🤖 AIコメント\n${mealData['comment']}'),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final double nutritionPriority;
  final double quickPriority;
  final double easyPriority;
  final double newPriority;
  final Function(String) onFavorite;
  final Function(String) onHistory;

  const HomePage({
    super.key,
    required this.nutritionPriority,
    required this.quickPriority,
    required this.easyPriority,
    required this.newPriority,
    required this.onFavorite,
    required this.onHistory,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MenuGenerator _menuGenerator = const MenuGenerator();
  Recipe selectedRecipe = recipes.firstWhere(
    (recipe) => recipe.name == '親子丼',
    orElse: () => recipes.first,
  );

  String get menu => selectedRecipe.name;

  String getAiComment() {
    if (widget.nutritionPriority >= widget.quickPriority &&
        widget.nutritionPriority >= widget.easyPriority &&
        widget.nutritionPriority >= widget.newPriority) {
      return '今日は栄養バランスを重視した献立を提案します！';
    }

    if (widget.quickPriority >= widget.nutritionPriority &&
        widget.quickPriority >= widget.easyPriority &&
        widget.quickPriority >= widget.newPriority) {
      return '今日は忙しい方向けの時短献立です！';
    }

    if (widget.easyPriority >= widget.nutritionPriority &&
        widget.easyPriority >= widget.quickPriority &&
        widget.easyPriority >= widget.newPriority) {
      return '今日は簡単に作れる献立を提案します！';
    }

    return '今日は新しい料理にチャレンジしてみましょう！';
  }

  String aiAdvice = '忙しい日なので、時短で作れる献立を選びました😊';
  String mode = '忙しい';
  bool isFavorite = false;

  void generateMenu() {
    final recommendation = _menuGenerator.recommend(
      recipes: recipes,
      weights: PriorityWeights(
        nutrition: widget.nutritionPriority,
        quick: widget.quickPriority,
        easy: widget.easyPriority,
        fresh: widget.newPriority,
      ),
    );

    setState(() {
      selectedRecipe = recommendation.recipe;
      isFavorite = false;
      aiAdvice =
          '${recommendation.reason} スコアは${recommendation.score.toStringAsFixed(1)}点です😊';
    });

    widget.onHistory(recommendation.recipe.name);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KONDATE AI'),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.sentiment_satisfied),
              title: Text('今日の状態：忙しい'),
              subtitle: Text('今日は忙しそうなので時短レシピを優先しています！'),
            ),
          ),
          SizedBox(height: 20),
          Text(
            '今日のおすすめ献立',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          const SizedBox(height: 10),

          Text(
            getAiComment(),
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    mode = '忙しい';
                  });
                },
                child: const Text('忙しい'),
              ),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    mode = '普通';
                  });
                },
                child: const Text('普通'),
              ),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    mode = '余裕ある';
                  });
                },
                child: const Text('余裕ある'),
              ),
            ],
          ),

          const SizedBox(height: 20),
          MealCard(
            title: menu,
            time: selectedRecipe.time,
            tags: selectedRecipe.tags,
            locked: false,
          ),
          const SizedBox(height: 12),

          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                isFavorite = !isFavorite;
                widget.onFavorite(menu);
              });
            },
            icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
            label: Text(isFavorite ? 'お気に入り済み' : 'お気に入り'),
          ),

          ElevatedButton.icon(
            onPressed: generateMenu,
            icon: const Icon(Icons.smart_toy),
            label: const Text('AI献立生成'),
          ),
          SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: Icon(Icons.smart_toy),
              title: Text('AIからのアドバイス'),
              subtitle: Text(aiAdvice),
            ),
          ),
        ],
      ),
    );
  }
}

class WeeklyPlanPage extends StatefulWidget {
  const WeeklyPlanPage({super.key});

  @override
  State<WeeklyPlanPage> createState() => _WeeklyPlanPageState();
}

class _WeeklyPlanPageState extends State<WeeklyPlanPage> {
  String mode = '普通';
  List<Map<String, dynamic>> meals = [
    {'day': '今日', 'title': '親子丼', 'time': '20分', 'locked': false},
    {'day': '明日', 'title': '焼きそば', 'time': '15分', 'locked': false},
    {'day': '明後日', 'title': 'カレーライス', 'time': '35分', 'locked': false},
    {'day': '4日目', 'title': 'ハンバーグ', 'time': '30分', 'locked': false},
    {'day': '5日目', 'title': 'オムライス', 'time': '25分', 'locked': false},
    {'day': '6日目', 'title': '豚の生姜焼き', 'time': '25分', 'locked': false},
    {'day': '7日目', 'title': '焼きそば', 'time': '15分', 'locked': false},
  ];
  void generateWeeklyMeals() {
    setState(() {
      if (mode == '忙しい') {
        meals = [
          {'day': '今日', 'title': '親子丼', 'time': '20分', 'locked': false},
          {'day': '明日', 'title': '焼きそば', 'time': '15分', 'locked': false},
          {'day': '明後日', 'title': 'カレーライス', 'time': '35分', 'locked': false},
          {'day': '4日目', 'title': 'ハンバーグ', 'time': '30分', 'locked': false},
          {'day': '5日目', 'title': 'オムライス', 'time': '25分', 'locked': false},
          {'day': '6日目', 'title': '豚の生姜焼き', 'time': '25分', 'locked': false},
          {'day': '7日目', 'title': '焼きそば', 'time': '15分', 'locked': false},
        ];
      } else if (mode == '普通') {
        meals = [
          {'day': '今日', 'title': '親子丼', 'time': '20分', 'locked': false},
          {'day': '明日', 'title': '焼きそば', 'time': '15分', 'locked': false},
          {'day': '明後日', 'title': 'カレーライス', 'time': '35分', 'locked': false},
          {'day': '4日目', 'title': 'ハンバーグ', 'time': '30分', 'locked': false},
          {'day': '5日目', 'title': 'オムライス', 'time': '25分', 'locked': false},
          {'day': '6日目', 'title': '豚の生姜焼き', 'time': '25分', 'locked': false},
          {'day': '7日目', 'title': '焼きそば', 'time': '15分', 'locked': false},
        ];
      } else {
        meals = [
          {'day': '今日', 'title': '親子丼', 'time': '20分', 'locked': false},
          {'day': '明日', 'title': '焼きそば', 'time': '15分', 'locked': false},
          {'day': '明後日', 'title': 'カレーライス', 'time': '35分', 'locked': false},
          {'day': '4日目', 'title': 'ハンバーグ', 'time': '30分', 'locked': false},
          {'day': '5日目', 'title': 'オムライス', 'time': '25分', 'locked': false},
          {'day': '6日目', 'title': '豚の生姜焼き', 'time': '25分', 'locked': false},
          {'day': '7日目', 'title': '焼きそば', 'time': '15分', 'locked': false},
        ];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('週間献立'), backgroundColor: Colors.orange),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    mode = '忙しい';
                  });
                },
                child: const Text('忙しい'),
              ),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    mode = '普通';
                  });
                },
                child: const Text('普通'),
              ),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    mode = '余裕ある';
                  });
                },
                child: const Text('余裕ある'),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Card(
            color: Color(0xFFFFF3E0),
            child: ListTile(
              leading: Icon(Icons.lock_open),
              title: Text('無料版は3日先まで表示できます'),
              subtitle: Text('7日分の献立はプレミアムで解放'),
            ),
          ),
          ...meals.map(
            (meal) => MealCard(
              title: meal['title'] as String,
              time: meal['time'] as String,
              day: meal['day'] as String,
              tags: const ['#時短', '#和食', '#節約'],
              locked: meal['locked'] as bool,

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MealDetailPage(menu: meal['title'], onFavorite: null),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: generateWeeklyMeals,
            icon: const Icon(Icons.workspace_premium),
            label: const Text('プレミアムで7日分を見る'),
          ),
        ],
      ),
    );
  }
}

class MealCard extends StatelessWidget {
  final String title;
  final String time;
  final String? day;
  final List<String> tags;
  final bool locked;
  final VoidCallback? onTap;

  const MealCard({
    super.key,
    required this.title,
    required this.time,
    required this.tags,
    required this.locked,
    this.day,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: InkWell(
        onTap: locked ? null : onTap,
        child: ListTile(
          leading: locked
              ? const Icon(Icons.lock)
              : const Icon(Icons.restaurant_menu),
          title: Text(day == null ? title : '$day　$title'),
          subtitle: locked
              ? const Text('7日分の献立はプレミアム限定です')
              : Wrap(
                  spacing: 6,
                  children: [
                    Text(time),
                    ...tags.map((tag) => Chip(label: Text(tag))),
                  ],
                ),
          trailing: locked ? const Icon(Icons.chevron_right) : null,
        ),
      ),
    );
  }
}

class HistoryPage extends StatelessWidget {
  final List<String> historyMenus;

  const HistoryPage({super.key, required this.historyMenus});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('履歴'), backgroundColor: Colors.orange),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: historyMenus.isEmpty
            ? [
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.history),
                    title: Text('履歴はまだありません'),
                    subtitle: Text('AI献立生成するとここに表示されます'),
                  ),
                ),
              ]
            : historyMenus.map((menu) {
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(menu),
                    subtitle: const Text('AIが生成した献立'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MealDetailPage(menu: menu, onFavorite: null),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
      ),
    );
  }
}

class MyPage extends StatefulWidget {
  final List<String> favoriteMenus;
  final double nutritionPriority;
  final double quickPriority;
  final double easyPriority;
  final double newPriority;
  final Function(String) onRemoveFavorite;
  final void Function({
    required double nutritionPriority,
    required double quickPriority,
    required double easyPriority,
    required double newPriority,
  })
  onPrioritiesChanged;

  const MyPage({
    super.key,
    required this.favoriteMenus,
    required this.nutritionPriority,
    required this.quickPriority,
    required this.easyPriority,
    required this.newPriority,
    required this.onRemoveFavorite,
    required this.onPrioritiesChanged,
  });

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  double nutritionPriority = 40;
  String getAiComment() {
    if (nutritionPriority >= quickPriority &&
        nutritionPriority >= easyPriority &&
        nutritionPriority >= newPriority) {
      return '今日は栄養バランスを重視した献立を提案します！';
    }

    if (quickPriority >= nutritionPriority &&
        quickPriority >= easyPriority &&
        quickPriority >= newPriority) {
      return '今日は忙しい方向けの時短献立です！';
    }

    if (easyPriority >= nutritionPriority &&
        easyPriority >= quickPriority &&
        easyPriority >= newPriority) {
      return '今日は簡単に作れる献立を提案します！';
    }

    return '今日は新しい料理にチャレンジしてみましょう！';
  }

  double quickPriority = 20;
  double easyPriority = 20;
  double newPriority = 20;
  @override
  void initState() {
    super.initState();
    _syncPrioritiesFromWidget();
  }

  @override
  void didUpdateWidget(covariant MyPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.nutritionPriority != widget.nutritionPriority ||
        oldWidget.quickPriority != widget.quickPriority ||
        oldWidget.easyPriority != widget.easyPriority ||
        oldWidget.newPriority != widget.newPriority) {
      _syncPrioritiesFromWidget();
    }
  }

  void _syncPrioritiesFromWidget() {
    nutritionPriority = widget.nutritionPriority;
    quickPriority = widget.quickPriority;
    easyPriority = widget.easyPriority;
    newPriority = widget.newPriority;
  }

  void _notifyPrioritiesChanged() {
    widget.onPrioritiesChanged(
      nutritionPriority: nutritionPriority,
      quickPriority: quickPriority,
      easyPriority: easyPriority,
      newPriority: newPriority,
    );
  }

  Widget prioritySlider(
    String title,
    double value,
    Function(double) onChanged,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(title), Text('${value.toInt()}%')],
            ),
            Slider(
              value: value,
              min: 0,
              max: 100,
              divisions: 20,
              label: value.toInt().toString(),
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('マイページ'),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),

          const Text(
            'お気に入り献立',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          if (widget.favoriteMenus.isEmpty)
            const Text('お気に入りはまだありません')
          else
            ...widget.favoriteMenus.map(
              (menu) => Card(
                child: ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.red),
                  title: Text(menu),
                ),
              ),
            ),
          const SizedBox(height: 24),

          const Text(
            'AI優先度設定',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          prioritySlider('栄養バランス', nutritionPriority, (v) {
            setState(() {
              nutritionPriority = v;
            });

            _notifyPrioritiesChanged();
          }),

          prioritySlider('時短', quickPriority, (v) {
            setState(() {
              quickPriority = v;
            });
            _notifyPrioritiesChanged();
          }),

          prioritySlider('簡単さ', easyPriority, (v) {
            setState(() {
              easyPriority = v;
            });
            _notifyPrioritiesChanged();
          }),

          prioritySlider('新しい献立', newPriority, (v) {
            setState(() {
              newPriority = v;
            });
            _notifyPrioritiesChanged();
          }),

          const SizedBox(height: 12),

          const SizedBox(height: 24),
          const SizedBox(height: 8),

          if (widget.favoriteMenus.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.favorite_border),
                title: Text('まだお気に入りはありません'),
                subtitle: Text('ホームで献立をお気に入り登録するとここに表示されます'),
              ),
            )
          else
            ...widget.favoriteMenus.map(
              (menu) => Card(
                child: ListTile(
                  leading: const Icon(Icons.favorite),
                  title: Text(menu),
                  subtitle: const Text('お気に入りに追加された献立'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      widget.onRemoveFavorite(menu);
                    },
                  ),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MealDetailPage(menu: menu, onFavorite: null),
                      ),
                    );
                  },
                ),
              ),
            ),

          const Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.orange,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text('ゆうとさん'),
              subtitle: Text('無料プラン利用中'),
            ),
          ),

          const SizedBox(height: 16),
          _menuTile(Icons.people, '人数設定', '4人'),
          _menuTile(Icons.sentiment_satisfied, '忙しさ設定', '平日：忙しい'),
          _menuTile(Icons.tune, 'AI優先度設定', '時短 ＞ 栄養 ＞ 季節'),
          _menuTile(Icons.no_food, '苦手食材', 'ピーマン・なす'),
          _menuTile(Icons.health_and_safety, 'アレルギー', 'なし'),
          _menuTile(Icons.notifications, '通知設定', 'オン'),
          _menuTile(Icons.workspace_premium, 'プレミアム管理', '7日分献立を解放'),
          _menuTile(Icons.help_outline, 'ヘルプ・お問い合わせ', ''),
        ],
      ),
    );
  }

  static Widget _menuTile(IconData icon, String title, String subtitle) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.orange),
        title: Text(title),
        subtitle: subtitle.isEmpty ? null : Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
