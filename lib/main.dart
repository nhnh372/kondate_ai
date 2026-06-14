import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  @override
  void initState() {
    super.initState();
    loadFavorites();
    loadHistory();
  }

  String favoriteMenu = '';
  bool isFavorite = false;

  List<String> historyMenus = [];

  List<String> favoriteMenus = [];

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
    HomePage(onFavorite: toggleFavorite, onHistory: addHistory),
    WeeklyPlanPage(),
    HistoryPage(historyMenus: historyMenus),
    MyPage(favoriteMenus: favoriteMenus),
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

class MealDetailPage extends StatelessWidget {
  final String menu;

  const MealDetailPage({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(menu)),
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

            const Text('🛒 材料\n・サンプル食材', style: TextStyle(fontSize: 18)),

            const SizedBox(height: 20),

            const Text('👨‍🍳 作り方\n1. サンプル手順', style: TextStyle(fontSize: 18)),

            const SizedBox(height: 20),

            const Text(
              '🤖 AIコメント\n今日はおすすめの献立です！',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final Function(String) onFavorite;
  final Function(String) onHistory;

  const HomePage({
    super.key,
    required this.onFavorite,
    required this.onHistory,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String menu = '親子丼';
  String aiAdvice = '忙しい日なので、時短で作れる献立を選びました😊';
  String mode = '忙しい';
  bool isFavorite = false;
  void generateMenu() {
    List<String> menus;

    if (mode == '忙しい') {
      menus = ['親子丼', 'カレーライス', '焼きそば'];
    } else if (mode == '普通') {
      menus = ['ハンバーグ', 'オムライス', '豚の生姜焼き'];
    } else {
      menus = ['豚の角煮', 'ロールキャベツ', 'ビーフシチュー'];
    }
    menus.shuffle();

    setState(() {
      menu = menus.first;

      widget.onHistory(menu);

      if (mode == '忙しい') {
        aiAdvice = '忙しい日なので、時短で作れて洗い物が少ない献立を選びました😊';
      } else if (mode == '普通') {
        aiAdvice = '今日は栄養バランスと満足感を考えた献立を提案しました🥗';
      } else {
        aiAdvice = '今日は時間に余裕があるので、少し手間をかけたごちそう献立を選びました🍳';
      }
    });
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
            time: '20分',
            tags: ['#時短', '#和食', '#節約', '#初挑戦'],
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
    {'day': '明日', 'title': 'カレーライス', 'time': '35分', 'locked': false},
    {'day': '明後日', 'title': '豚の生姜焼き', 'time': '25分', 'locked': false},
    {'day': '4日目', 'title': 'プレミアムで解放', 'time': '', 'locked': true},
    {'day': '5日目', 'title': 'プレミアムで解放', 'time': '', 'locked': true},
    {'day': '6日目', 'title': 'プレミアムで解放', 'time': '', 'locked': true},
    {'day': '7日目', 'title': 'プレミアムで解放', 'time': '', 'locked': true},
  ];
  void generateWeeklyMeals() {
    setState(() {
      if (mode == '忙しい') {
        meals = [
          {'day': '今日', 'title': '親子丼', 'time': '20分', 'locked': false},
          {'day': '明日', 'title': '焼きそば', 'time': '15分', 'locked': false},
          {'day': '明後日', 'title': 'カレーライス', 'time': '30分', 'locked': false},
          {'day': '4日目', 'title': 'プレミアムで解放', 'time': '', 'locked': true},
          {'day': '5日目', 'title': 'プレミアムで解放', 'time': '', 'locked': true},
          {'day': '6日目', 'title': 'プレミアムで解放', 'time': '', 'locked': true},
          {'day': '7日目', 'title': 'プレミアムで解放', 'time': '', 'locked': true},
        ];
      } else if (mode == '普通') {
        meals = [
          {'day': '今日', 'title': 'ハンバーグ', 'time': '35分', 'locked': false},
          {'day': '明日', 'title': 'オムライス', 'time': '25分', 'locked': false},
          {'day': '明後日', 'title': '豚の生姜焼き', 'time': '25分', 'locked': false},
          {'day': '4日目', 'title': 'プレミアムで解放', 'time': '', 'locked': true},
          {'day': '5日目', 'title': 'プレミアムで解放', 'time': '', 'locked': true},
          {'day': '6日目', 'title': 'プレミアムで解放', 'time': '', 'locked': true},
          {'day': '7日目', 'title': 'プレミアムで解放', 'time': '', 'locked': true},
        ];
      } else {
        meals = [
          {'day': '今日', 'title': 'ロールキャベツ', 'time': '60分', 'locked': false},
          {'day': '明日', 'title': 'ビーフシチュー', 'time': '90分', 'locked': false},
          {'day': '明後日', 'title': '豚の角煮', 'time': '80分', 'locked': false},
          {'day': '4日目', 'title': 'プレミアムで解放', 'time': '', 'locked': true},
          {'day': '5日目', 'title': 'プレミアムで解放', 'time': '', 'locked': true},
          {'day': '6日目', 'title': 'プレミアムで解放', 'time': '', 'locked': true},
          {'day': '7日目', 'title': 'プレミアムで解放', 'time': '', 'locked': true},
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

  const MealCard({
    super.key,
    required this.title,
    required this.time,
    required this.tags,
    required this.locked,
    this.day,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 12),
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
                          builder: (context) => MealDetailPage(menu: menu),
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

class MyPage extends StatelessWidget {
  final List<String> favoriteMenus;

  const MyPage({super.key, required this.favoriteMenus});

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

          const SizedBox(height: 8),

          if (favoriteMenus.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.favorite_border),
                title: Text('まだお気に入りはありません'),
                subtitle: Text('ホームで献立をお気に入り登録するとここに表示されます'),
              ),
            )
          else
            ...favoriteMenus.map(
              (menu) => Card(
                child: ListTile(
                  leading: const Icon(Icons.favorite),
                  title: Text(menu),
                  subtitle: const Text('お気に入りに追加された献立'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MealDetailPage(menu: menu),
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
