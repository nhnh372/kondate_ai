import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/recipes.dart';
import 'models/recipe.dart';
import 'models/weekly_plan.dart';
import 'repositories/favorite_repository.dart';
import 'repositories/meal_detail_repository.dart';
import 'repositories/weekly_plan_repository.dart';
import 'services/ai_comment_service.dart';
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
  final FavoriteRepository _favoriteRepository = const FavoriteRepository();
  int currentIndex = 0;
  @override
  void initState() {
    super.initState();

    loadFavorites();
    loadHistory();
    loadPriorities();
  }

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

  Future<void> addFavorite(String menu) async {
    final updatedFavorites = await _favoriteRepository.addFavorite(menu);

    if (!mounted) {
      return;
    }

    setState(() {
      favoriteMenus = updatedFavorites;
    });
  }

  Future<void> removeFavorite(String menu) async {
    final updatedFavorites = await _favoriteRepository.removeFavorite(menu);

    if (!mounted) {
      return;
    }

    setState(() {
      favoriteMenus = updatedFavorites;
    });
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
    final savedFavorites = await _favoriteRepository.loadFavorites();

    if (!mounted) {
      return;
    }

    setState(() {
      favoriteMenus = savedFavorites;
    });
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

  void openWeeklyPlan() {
    setState(() {
      currentIndex = 1;
    });
  }

  List<Widget> get pages => [
    HomePage(
      nutritionPriority: nutritionPriority,
      quickPriority: quickPriority,
      easyPriority: easyPriority,
      newPriority: newPriority,
      isFavoriteForMenu: favoriteMenus.contains,
      onFavorite: addFavorite,
      onHistory: addHistory,
      onOpenWeeklyPlan: openWeeklyPlan,
    ),
    WeeklyPlanPage(
      nutritionPriority: nutritionPriority,
      quickPriority: quickPriority,
      easyPriority: easyPriority,
      newPriority: newPriority,
    ),
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

class MealDetailPage extends StatelessWidget {
  final String menu;
  final String category;
  final Future<void> Function(String)? onFavorite;

  const MealDetailPage({
    super.key,
    required this.menu,
    this.category = '主菜',
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    const detailRepository = MealDetailRepository();
    const aiCommentService = AiCommentService();
    final detail = detailRepository.findByName(menu, category: category);
    final recipe = AiRecommendationInfo.findRecipe(menu);

    return Scaffold(
      appBar: AppBar(
        title: Text(menu),
        actions: [
          if (onFavorite != null)
            IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () async {
                await onFavorite?.call(menu);

                if (!context.mounted) {
                  return;
                }

                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('$menu をお気に入りに保存しました')));
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          RecipeImage(recipeName: detail.name, height: 210),
          const SizedBox(height: 16),
          AiRecommendationCard(recipeName: detail.name, recipe: recipe),
          const SizedBox(height: 12),
          Text(
            detail.name,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                avatar: const Icon(Icons.category, size: 18),
                label: Text(detail.category),
              ),
              Chip(
                avatar: const Icon(Icons.timer, size: 18),
                label: Text(detail.time),
              ),
            ],
          ),
          const SizedBox(height: 12),
          MealDetailSection(
            icon: Icons.smart_toy,
            title: 'AIコメント',
            child: Text(
              '${detail.comment}\n${aiCommentService.detailComment(detail)}',
            ),
          ),
          MealDetailSection(
            icon: Icons.shopping_basket,
            title: '材料',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: detail.ingredients
                  .map((ingredient) => Text('・$ingredient'))
                  .toList(),
            ),
          ),
          MealDetailSection(
            icon: Icons.format_list_numbered,
            title: '作り方',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: detail.steps.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('${entry.key + 1}. ${entry.value}'),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class MealDetailSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const MealDetailSection({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  static const initialRecipeName = '親子丼';

  final double nutritionPriority;
  final double quickPriority;
  final double easyPriority;
  final double newPriority;
  final bool Function(String) isFavoriteForMenu;
  final Future<void> Function(String) onFavorite;
  final void Function(String) onHistory;
  final VoidCallback onOpenWeeklyPlan;

  const HomePage({
    super.key,
    required this.nutritionPriority,
    required this.quickPriority,
    required this.easyPriority,
    required this.newPriority,
    required this.isFavoriteForMenu,
    required this.onFavorite,
    required this.onHistory,
    required this.onOpenWeeklyPlan,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MenuGenerator _menuGenerator = const MenuGenerator();
  final AiCommentService _aiCommentService = const AiCommentService();
  Recipe selectedRecipe = recipes.firstWhere(
    (recipe) => recipe.name == HomePage.initialRecipeName,
    orElse: () => recipes.first,
  );

  String get menu => selectedRecipe.name;

  PriorityWeights get priorityWeights => PriorityWeights(
    nutrition: widget.nutritionPriority,
    quick: widget.quickPriority,
    easy: widget.easyPriority,
    fresh: widget.newPriority,
  );

  String getAiComment() {
    return _aiCommentService.priorityComment(priorityWeights);
  }

  String aiAdvice = '忙しい日なので、時短で作れる献立を選びました😊';
  String mode = '忙しい';

  void generateMenu() {
    final recommendation = _menuGenerator.recommend(
      recipes: recipes,
      weights: priorityWeights,
    );

    setState(() {
      selectedRecipe = recommendation.recipe;
      aiAdvice =
          '${recommendation.reason} スコアは${recommendation.score.toStringAsFixed(1)}点です😊';
    });

    widget.onHistory(recommendation.recipe.name);
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentFavorite = widget.isFavoriteForMenu(menu);
    final statusMessage = switch (mode) {
      '忙しい' => '今日は忙しいので、時短で洗い物少なめを意識しています。',
      '余裕ある' => '今日は少し余裕があるので、栄養バランスと新しさを足しています。',
      _ => '今日は無理なく作れる、家族で食べやすい献立を選びます。',
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('KONDATE AI'),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: const Color(0xFFFFF3E0),
            child: ListTile(
              leading: const Icon(Icons.home_rounded, color: Colors.orange),
              title: Text('今日の状態：$mode'),
              subtitle: Text(statusMessage),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '今日のおすすめ献立',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('忙しい'),
                selected: mode == '忙しい',
                avatar: const Icon(Icons.flash_on, size: 18),
                onSelected: (_) => setState(() => mode = '忙しい'),
              ),
              ChoiceChip(
                label: const Text('普通'),
                selected: mode == '普通',
                avatar: const Icon(Icons.sentiment_satisfied, size: 18),
                onSelected: (_) => setState(() => mode = '普通'),
              ),
              ChoiceChip(
                label: const Text('余裕ある'),
                selected: mode == '余裕ある',
                avatar: const Icon(Icons.restaurant, size: 18),
                onSelected: (_) => setState(() => mode = '余裕ある'),
              ),
            ],
          ),

          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: generateMenu,
            icon: const Icon(Icons.smart_toy),
            label: const Text('AI献立生成'),
          ),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: isCurrentFavorite
                ? null
                : () async {
                    await widget.onFavorite(menu);

                    if (!context.mounted) {
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('$menu をお気に入りに保存しました')),
                    );
                  },
            icon: Icon(
              isCurrentFavorite ? Icons.favorite : Icons.favorite_border,
            ),
            label: Text(isCurrentFavorite ? 'お気に入り済み' : 'お気に入り保存'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: widget.onOpenWeeklyPlan,
            icon: const Icon(Icons.calendar_month),
            label: const Text('週間献立を見る'),
          ),
          const SizedBox(height: 12),
          _TodayRecommendationCard(
            recipe: selectedRecipe,
            suggestionReason: getAiComment(),
            aiAdvice: aiAdvice,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      MealDetailPage(menu: menu, onFavorite: widget.onFavorite),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Card(
            color: const Color(0xFFFFFCF7),
            child: ListTile(
              leading: const Icon(Icons.auto_awesome, color: Colors.orange),
              title: const Text('今日の提案理由'),
              subtitle: Text('$aiAdvice\n子どもも食べやすく、栄養バランスも見ています。'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayRecommendationCard extends StatelessWidget {
  final Recipe recipe;
  final String suggestionReason;
  final String aiAdvice;
  final VoidCallback onTap;

  const _TodayRecommendationCard({
    required this.recipe,
    required this.suggestionReason,
    required this.aiAdvice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFFCF7),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RecipeImage(recipeName: recipe.name, height: 190),
              const SizedBox(height: 14),
              AiRecommendationCard(
                recipeName: recipe.name,
                recipe: recipe,
                compact: true,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      suggestionReason,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                recipe.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _RecipeInfoChip(
                    icon: Icons.timer,
                    label: recipe.time,
                    color: Colors.orange,
                  ),
                  const _RecipeInfoChip(
                    icon: Icons.cleaning_services,
                    label: '洗い物少なめ',
                    color: Colors.teal,
                  ),
                  const _RecipeInfoChip(
                    icon: Icons.child_care,
                    label: '子ども向け',
                    color: Colors.pink,
                  ),
                  ...recipe.tags.map(
                    (tag) => _RecipeInfoChip(
                      icon: Icons.label,
                      label: tag,
                      color: Colors.brown,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(aiAdvice),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _RecipeInfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      backgroundColor: Color.lerp(Colors.white, color, 0.08),
      side: BorderSide(color: Color.lerp(Colors.white, color, 0.25)!),
    );
  }
}

class RecipeImage extends StatelessWidget {
  final String recipeName;
  final double height;

  const RecipeImage({
    super.key,
    required this.recipeName,
    required this.height,
  });

  static const String _assetBasePath = 'lib/assets/images/recipes';

  String? get assetPath {
    final fileName = _assetFileNames[recipeName];

    if (fileName == null) {
      return null;
    }

    return '$_assetBasePath/$fileName';
  }

  static const Map<String, String> _assetFileNames = {
    '親子丼': 'oyakodon.jpg',
    'カレーライス': 'curry_rice.jpg',
    '焼きそば': 'yakisoba.jpg',
    'ハンバーグ': 'hamburg.jpg',
    'オムライス': 'omurice.jpg',
    '豚の生姜焼き': 'pork_ginger.jpg',
    '鮭のホイル焼き': 'salmon_foil.jpg',
    'ビビンバ': 'bibimbap.jpg',
    '生姜焼き': 'ginger_pork.jpg',
    '麻婆豆腐': 'mapo_tofu.jpg',
    'サバの味噌煮': 'saba_miso.jpg',
    '冷やし中華': 'hiyashi_chuka.jpg',
  };

  @override
  Widget build(BuildContext context) {
    final path = assetPath;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: path == null
            ? const _NoRecipeImagePlaceholder()
            : Image.asset(
                path,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const _NoRecipeImagePlaceholder();
                },
              ),
      ),
    );
  }
}

class _NoRecipeImagePlaceholder extends StatelessWidget {
  const _NoRecipeImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restaurant_menu, color: Colors.orange, size: 42),
            SizedBox(height: 8),
            Text(
              'No Image',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AiRecommendationInfo {
  const AiRecommendationInfo._();

  static const int fallbackScore = 78;

  static Recipe? findRecipe(String recipeName) {
    for (final recipe in recipes) {
      if (recipe.name == recipeName) {
        return recipe;
      }
    }

    return null;
  }

  static int scoreFor(Recipe? recipe) {
    return recipe?.aiScore ?? fallbackScore;
  }

  static String starsFor(int score) {
    if (score >= 95) {
      return '★★★★★';
    }

    if (score >= 85) {
      return '★★★★☆';
    }

    if (score >= 70) {
      return '★★★☆☆';
    }

    if (score >= 50) {
      return '★★☆☆☆';
    }

    return '★☆☆☆☆';
  }

  static List<String> reasonTagsFor(Recipe? recipe) {
    if (recipe == null) {
      return const ['家庭向け', '組み合わせやすい', '献立調整'];
    }

    final tags = <String>[];

    if (recipe.nutrition >= 80) {
      tags.add('栄養バランス');
    }

    if (recipe.quick >= 80) {
      tags.add('時短');
    }

    if (recipe.easy >= 80) {
      tags.add('簡単');
    }

    if (recipe.fresh >= 80) {
      tags.add('新しさ');
    }

    tags.add('子ども向け');
    tags.add('洗い物少ない');

    return tags.take(5).toList();
  }
}

class AiRecommendationCard extends StatelessWidget {
  final String recipeName;
  final Recipe? recipe;
  final bool compact;

  const AiRecommendationCard({
    super.key,
    required this.recipeName,
    required this.recipe,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final score = AiRecommendationInfo.scoreFor(recipe);
    final stars = AiRecommendationInfo.starsFor(score);
    final reasonTags = AiRecommendationInfo.reasonTagsFor(recipe);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? 10 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.psychology, color: Colors.orange, size: 20),
                const SizedBox(width: 6),
                Text(
                  'AIおすすめ $score点',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  stars,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: compact ? 8 : 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: reasonTags
                  .map((tag) => _AiReasonTag(label: tag))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiReasonTag extends StatelessWidget {
  final String label;

  const _AiReasonTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.orange.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class WeeklyPlanPage extends StatefulWidget {
  final double nutritionPriority;
  final double quickPriority;
  final double easyPriority;
  final double newPriority;

  const WeeklyPlanPage({
    super.key,
    required this.nutritionPriority,
    required this.quickPriority,
    required this.easyPriority,
    required this.newPriority,
  });

  @override
  State<WeeklyPlanPage> createState() => _WeeklyPlanPageState();
}

class _WeeklyPlanPageState extends State<WeeklyPlanPage> {
  final WeeklyPlanRepository _weeklyPlanRepository =
      const WeeklyPlanRepository();
  final AiCommentService _aiCommentService = const AiCommentService();
  late WeeklyPlan weeklyPlan;
  int generationIndex = 0;

  @override
  void initState() {
    super.initState();
    weeklyPlan = _generateWeeklyPlan();
  }

  @override
  void didUpdateWidget(covariant WeeklyPlanPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.nutritionPriority != widget.nutritionPriority ||
        oldWidget.quickPriority != widget.quickPriority ||
        oldWidget.easyPriority != widget.easyPriority ||
        oldWidget.newPriority != widget.newPriority) {
      weeklyPlan = _generateWeeklyPlan();
    }
  }

  WeeklyPlan _generateWeeklyPlan() {
    return _weeklyPlanRepository.generate(
      weights: priorityWeights,
      generationIndex: generationIndex,
    );
  }

  PriorityWeights get priorityWeights => PriorityWeights(
    nutrition: widget.nutritionPriority,
    quick: widget.quickPriority,
    easy: widget.easyPriority,
    fresh: widget.newPriority,
  );

  void regenerateWeeklyPlan() {
    setState(() {
      generationIndex += 1;
      weeklyPlan = _generateWeeklyPlan();
    });
  }

  void openShoppingList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShoppingListPage(weeklyPlan: weeklyPlan),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final averageNutrition = weeklyPlan.averageNutritionBalance;
    final aiComment = _aiCommentService.weeklyPlanComment(
      weeklyPlan,
      priorityWeights,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('週間献立'), backgroundColor: Colors.orange),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _WeeklyAiCommentCard(comment: aiComment),
          const SizedBox(height: 14),
          const Text(
            '今週の献立サマリー',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 68,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _WeeklySummaryTile(
                  icon: Icons.calendar_month,
                  label: '期間',
                  value: '${weeklyPlan.days.length}日',
                ),
                const _WeeklySummaryTile(
                  icon: Icons.restaurant_menu,
                  label: '構成',
                  value: '主菜・副菜・汁物',
                ),
                _WeeklySummaryTile(
                  icon: Icons.timer,
                  label: '調理時間',
                  value: '${weeklyPlan.totalMinutes}分',
                ),
                _WeeklySummaryTile(
                  icon: Icons.payments,
                  label: '概算食費',
                  value: '${weeklyPlan.totalCostYen}円',
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _WeeklyNutritionCard(balance: averageNutrition),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: openShoppingList,
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('買い物リスト'),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                onPressed: regenerateWeeklyPlan,
                icon: const Icon(Icons.refresh),
                tooltip: '週間献立を再生成',
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...weeklyPlan.days.map(
            (dayPlan) => WeeklyDayPlanCard(
              dayPlan: dayPlan,
              onOpenMeal: (item) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MealDetailPage(menu: item.name, category: item.label),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ShoppingListPage extends StatelessWidget {
  final WeeklyPlan weeklyPlan;

  const ShoppingListPage({super.key, required this.weeklyPlan});

  @override
  Widget build(BuildContext context) {
    final items = weeklyPlan.shoppingItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('買い物リスト'),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: const Color(0xFFFFF8E1),
            child: ListTile(
              leading: const Icon(Icons.shopping_basket, color: Colors.orange),
              title: const Text('1週間分の材料メモ'),
              subtitle: Text('主菜・副菜・汁物から${items.length}件を仮集計しています。'),
            ),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('買い物リストはまだありません'),
                subtitle: Text('週間献立を作成すると、ここに材料候補が表示されます。'),
              ),
            )
          else
            ...items.map((item) => _ShoppingListItem(name: item)),
        ],
      ),
    );
  }
}

class _ShoppingListItem extends StatelessWidget {
  final String name;

  const _ShoppingListItem({required this.name});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: CheckboxListTile(
        value: false,
        onChanged: (_) {},
        controlAffinity: ListTileControlAffinity.leading,
        title: Text(name),
      ),
    );
  }
}

class _WeeklyAiCommentCard extends StatelessWidget {
  final String comment;

  const _WeeklyAiCommentCard({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFFFF3E0),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        leading: const Icon(Icons.smart_toy, color: Colors.orange, size: 22),
        minTileHeight: 58,
        title: const Text(
          'AIが1週間の献立を提案しました',
          style: TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: const Text('栄養バランスを重視して整えました'),
        children: [
          Align(alignment: Alignment.centerLeft, child: Text(comment)),
        ],
      ),
    );
  }
}

class _WeeklySummaryTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WeeklySummaryTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 108,
      child: Card(
        margin: const EdgeInsets.only(right: 6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.orange, size: 18),
              const SizedBox(height: 1),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 9, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeeklyNutritionCard extends StatelessWidget {
  final NutritionBalance balance;

  const _WeeklyNutritionCard({required this.balance});

  int get averageScore =>
      ((balance.protein + balance.vegetable + balance.energy) / 3).round();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
        leading: const Icon(Icons.monitor_heart, color: Colors.orange),
        title: Text(
          '栄養バランス $averageScore%',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: const Text('タップして詳細を見る'),
        children: [
          _NutritionBar(label: 'たんぱく質', value: balance.protein),
          _NutritionBar(label: '野菜量', value: balance.vegetable),
          _NutritionBar(label: 'エネルギー', value: balance.energy),
        ],
      ),
    );
  }
}

class _NutritionBar extends StatelessWidget {
  final String label;
  final int value;

  const _NutritionBar({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          SizedBox(width: 86, child: Text(label)),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: value / 100,
                minHeight: 9,
                backgroundColor: Colors.orange.shade50,
                color: Colors.orange,
              ),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 42,
            child: Text(
              '$value%',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class WeeklyDayPlanCard extends StatelessWidget {
  final WeeklyDayPlan dayPlan;
  final ValueChanged<WeeklyMealItem> onOpenMeal;

  const WeeklyDayPlanCard({
    super.key,
    required this.dayPlan,
    required this.onOpenMeal,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 8),
      color: const Color(0xFFFFFCF7),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    dayPlan.dayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _DayInfoChip(
                  icon: Icons.timer,
                  label: '約${dayPlan.cookingMinutes}分',
                ),
                const SizedBox(width: 4),
                _DayInfoChip(
                  icon: Icons.payments,
                  label: '約${dayPlan.estimatedCostYen}円',
                ),
              ],
            ),
            const SizedBox(height: 4),
            WeeklyMealTile(
              item: dayPlan.mainDish,
              showTopBorder: false,
              onTap: () => onOpenMeal(dayPlan.mainDish),
            ),
            WeeklyMealTile(
              item: dayPlan.sideDish,
              onTap: () => onOpenMeal(dayPlan.sideDish),
            ),
            WeeklyMealTile(
              item: dayPlan.soup,
              onTap: () => onOpenMeal(dayPlan.soup),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DayInfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      labelPadding: EdgeInsets.zero,
      avatar: Icon(icon, size: 14, color: Colors.orange),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      side: BorderSide(color: Colors.orange.shade100),
      backgroundColor: Colors.white,
    );
  }
}

class WeeklyMealTile extends StatelessWidget {
  final WeeklyMealItem item;
  final bool showTopBorder;
  final VoidCallback onTap;

  const WeeklyMealTile({
    super.key,
    required this.item,
    required this.onTap,
    this.showTopBorder = true,
  });

  IconData get icon {
    switch (item.iconName) {
      case 'spa':
        return Icons.spa;
      case 'ramen_dining':
        return Icons.ramen_dining;
      default:
        return Icons.restaurant_menu;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _labelColor(item.label);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: showTopBorder
            ? Border(top: BorderSide(color: Colors.orange.shade100))
            : null,
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Row(
            children: [
              Container(
                width: 46,
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  item.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Color _labelColor(String label) {
    switch (label) {
      case '副菜':
        return Colors.green;
      case '汁物':
        return Colors.blueGrey;
      default:
        return Colors.orange;
    }
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
