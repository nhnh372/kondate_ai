import 'package:flutter/material.dart';

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

  final pages = const [HomePage(), WeeklyPlanPage(), HistoryPage(), MyPage()];

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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KONDATE AI'),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
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
          MealCard(
            title: '親子丼',
            time: '20分',
            tags: ['#時短', '#和食', '#節約', '#初挑戦'],
            locked: false,
          ),
          SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: Icon(Icons.smart_toy),
              title: Text('AIからのアドバイス'),
              subtitle: Text('忙しい日なので洗い物が少なく、家族人気の高い献立を選びました😊'),
            ),
          ),
        ],
      ),
    );
  }
}

class WeeklyPlanPage extends StatelessWidget {
  const WeeklyPlanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final meals = [
      {'day': '今日', 'title': '親子丼', 'time': '20分', 'locked': false},
      {'day': '明日', 'title': 'カレーライス', 'time': '35分', 'locked': false},
      {'day': '明後日', 'title': '豚の生姜焼き', 'time': '25分', 'locked': false},
      {'day': '4日目', 'title': 'プレミアムで解放', 'time': '', 'locked': true},
      {'day': '5日目', 'title': 'プレミアムで解放', 'time': '', 'locked': true},
      {'day': '6日目', 'title': 'プレミアムで解放', 'time': '', 'locked': true},
      {'day': '7日目', 'title': 'プレミアムで解放', 'time': '', 'locked': true},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('週間献立'), backgroundColor: Colors.orange),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
            onPressed: () {},
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
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('履歴'), backgroundColor: Colors.orange),
      body: const Center(child: Text('履歴ページ')),
    );
  }
}

class MyPage extends StatelessWidget {
  const MyPage({super.key});

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
