import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/clothing_item.dart';
import '../providers/clothing_provider.dart';
import '../providers/weather_provider.dart';
import '../widgets/glass_card.dart';
import 'clothing_detail_page.dart';

class OutfitRecommendationScreen extends StatefulWidget {
  const OutfitRecommendationScreen({super.key});

  @override
  State<OutfitRecommendationScreen> createState() => _OutfitRecommendationScreenState();
}

class _OutfitRecommendationScreenState extends State<OutfitRecommendationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isRefreshing = false;
  int _refreshKey = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _refreshRecommendation() async {
    setState(() {
      _isRefreshing = true;
    });
    
    _animationController.reset();
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    setState(() {
      _refreshKey++;
      _isRefreshing = false;
    });
    
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.arrow_back_ios_new, size: 18, color: cs.primary),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '今日穿搭推荐',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                        Text(
                          _getDateString(),
                          style: TextStyle(
                            fontSize: 13,
                            color: cs.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: _isRefreshing ? null : _refreshRecommendation,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _isRefreshing
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: cs.primary,
                              ),
                            )
                          : Icon(Icons.refresh, size: 18, color: cs.primary),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Weather Info Card
                      _buildWeatherInfoCard(context),
                      const SizedBox(height: 16),
                      
                      // Outfit Recommendation
                      _OutfitRecommendation(key: ValueKey(_refreshKey)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDateString() {
    final now = DateTime.now();
    final weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return '${now.month}月${now.day}日 ${weekdays[now.weekday - 1]}';
  }

  Widget _buildWeatherInfoCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Consumer<WeatherProvider>(
      builder: (context, provider, _) {
        if (!provider.hasData) {
          return GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.cloud_off, color: cs.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '暂无天气数据，推荐基于通用搭配',
                    style: TextStyle(
                      fontSize: 14,
                      color: cs.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final weather = provider.weather!;
        final suggestion = _getWeatherSuggestion(weather.currentTemp, weather.condition);

        return GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildWeatherIcon(weather.condition, size: 42),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${weather.currentTemp}°',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              weather.condition,
                              style: TextStyle(
                                fontSize: 16,
                                color: cs.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          provider.cityName ?? weather.cityName,
                          style: TextStyle(
                            fontSize: 13,
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.tips_and_updates, size: 18, color: cs.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        suggestion,
                        style: TextStyle(
                          fontSize: 13,
                          color: cs.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getWeatherSuggestion(int temp, String condition) {
    String suggestion = '';
    
    if (temp <= 5) {
      suggestion = '天气寒冷，建议穿厚外套、羽绒服，注意保暖';
    } else if (temp <= 15) {
      suggestion = '天气较凉，建议穿外套、卫衣，可适当搭配围巾';
    } else if (temp <= 22) {
      suggestion = '温度适宜，建议穿薄外套或长袖衬衫';
    } else if (temp <= 28) {
      suggestion = '天气温暖，建议穿短袖或薄长袖';
    } else {
      suggestion = '天气炎热，建议穿轻薄透气的衣物';
    }

    if (condition.contains('雨')) {
      suggestion += '，记得带伞';
    } else if (condition.contains('雪')) {
      suggestion += '，注意防寒防滑';
    }

    return suggestion;
  }

  Widget _buildWeatherIcon(String condition, {double size = 24}) {
    IconData icon;
    Color color;

    if (condition.contains('雨')) {
      icon = Icons.water_drop;
      color = Colors.blue;
    } else if (condition.contains('雪')) {
      icon = Icons.ac_unit;
      color = Colors.lightBlue;
    } else if (condition.contains('雷')) {
      icon = Icons.thunderstorm;
      color = Colors.deepPurple;
    } else if (condition.contains('云') || condition.contains('阴')) {
      icon = Icons.cloud;
      color = Colors.blueGrey;
    } else if (condition.contains('雾') || condition.contains('霾')) {
      icon = Icons.foggy;
      color = Colors.grey;
    } else if (condition.contains('晴')) {
      icon = Icons.wb_sunny;
      color = Colors.orange;
    } else {
      icon = Icons.cloud_outlined;
      color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: size - 10, color: color),
    );
  }
}

class _OutfitRecommendation extends StatelessWidget {
  const _OutfitRecommendation({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Consumer2<ClothingProvider, WeatherProvider>(
      builder: (context, clothingProvider, weatherProvider, _) {
        final activeItems = clothingProvider.activeClothing;
        
        if (activeItems.isEmpty) {
          return _buildEmptyState(context);
        }

        final recommendation = _generateRecommendation(
          activeItems,
          weatherProvider.weather?.currentTemp,
          weatherProvider.weather?.condition,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Outfit Display
            _buildMainOutfitCard(context, recommendation),
            const SizedBox(height: 20),

            // Category Recommendations
            Text(
              '分类推荐',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            
            ...recommendation.entries.map((entry) {
              return _buildCategorySection(context, entry.key, entry.value);
            }),

            const SizedBox(height: 20),

            // Style Tips
            _buildStyleTips(context),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GlassCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.checkroom, size: 48, color: cs.primary),
          ),
          const SizedBox(height: 20),
          Text(
            '衣橱还是空的',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '添加一些衣物后，我们会为你智能推荐穿搭',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: cs.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, ClothingItem?> _generateRecommendation(
    List<ClothingItem> items,
    int? temp,
    String? condition,
  ) {
    final random = Random();
    final recommendation = <String, ClothingItem?>{};

    // Define categories to recommend
    final categories = ['上衣', '裤子', '外套', '鞋子', '配饰'];

    for (final category in categories) {
      final categoryItems = items.where((item) {
        final itemCategory = item.category.toLowerCase();
        switch (category) {
          case '上衣':
            return itemCategory.contains('上衣') ||
                itemCategory.contains('衬衫') ||
                itemCategory.contains('T恤') ||
                itemCategory.contains('t恤') ||
                itemCategory.contains('卫衣') ||
                itemCategory.contains('毛衣');
          case '裤子':
            return itemCategory.contains('裤') ||
                itemCategory.contains('牛仔') ||
                itemCategory.contains('裙');
          case '外套':
            return itemCategory.contains('外套') ||
                itemCategory.contains('夹克') ||
                itemCategory.contains('羽绒') ||
                itemCategory.contains('大衣') ||
                itemCategory.contains('风衣');
          case '鞋子':
            return itemCategory.contains('鞋');
          case '配饰':
            return itemCategory.contains('帽') ||
                itemCategory.contains('围巾') ||
                itemCategory.contains('包') ||
                itemCategory.contains('配饰');
          default:
            return false;
        }
      }).toList();

      // Filter by season/temperature if available
      if (temp != null && categoryItems.isNotEmpty) {
        final seasonFiltered = categoryItems.where((item) {
          if (item.season.isEmpty) return true;
          
          if (temp <= 10) {
            return item.season.contains('冬') || item.season.contains('秋');
          } else if (temp <= 20) {
            return item.season.contains('春') || item.season.contains('秋');
          } else {
            return item.season.contains('夏') || item.season.contains('春');
          }
        }).toList();

        if (seasonFiltered.isNotEmpty) {
          recommendation[category] = seasonFiltered[random.nextInt(seasonFiltered.length)];
          continue;
        }
      }

      if (categoryItems.isNotEmpty) {
        recommendation[category] = categoryItems[random.nextInt(categoryItems.length)];
      } else {
        recommendation[category] = null;
      }
    }

    return recommendation;
  }

  Widget _buildMainOutfitCard(BuildContext context, Map<String, ClothingItem?> recommendation) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Get main items (top, bottom, outer)
    final mainItems = [
      recommendation['外套'],
      recommendation['上衣'],
      recommendation['裤子'],
    ].whereType<ClothingItem>().take(3).toList();

    if (mainItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [cs.primary, cs.primary.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    const Text(
                      '智能推荐',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '点击查看详情',
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Main outfit display
          SizedBox(
            height: 180,
            child: Row(
              children: mainItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isCenter = index == mainItems.length ~/ 2;
                
                return Expanded(
                  flex: isCenter ? 3 : 2,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClothingDetailPage(item: item),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.only(
                        left: index == 0 ? 0 : 6,
                        right: index == mainItems.length - 1 ? 0 : 6,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.05),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: cs.primary.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            item.imagePath.isNotEmpty
                                ? Image.file(
                                    File(item.imagePath),
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: cs.secondary,
                                    child: Icon(
                                      Icons.checkroom,
                                      size: 32,
                                      color: cs.onSurface.withValues(alpha: 0.3),
                                    ),
                                  ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.7),
                                    ],
                                  ),
                                ),
                                child: Text(
                                  item.category,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context, String category, ClothingItem? item) {
    final cs = Theme.of(context).colorScheme;

    if (item == null) return const SizedBox.shrink();

    IconData categoryIcon;
    switch (category) {
      case '上衣':
        categoryIcon = Icons.dry_cleaning;
        break;
      case '裤子':
        categoryIcon = Icons.accessibility_new;
        break;
      case '外套':
        categoryIcon = Icons.checkroom;
        break;
      case '鞋子':
        categoryIcon = Icons.ice_skating;
        break;
      case '配饰':
        categoryIcon = Icons.watch;
        break;
      default:
        categoryIcon = Icons.category;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ClothingDetailPage(item: item),
            ),
          );
        },
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 64,
                height: 64,
                child: item.imagePath.isNotEmpty
                    ? Image.file(File(item.imagePath), fit: BoxFit.cover)
                    : Container(
                        color: cs.secondary,
                        child: Icon(
                          categoryIcon,
                          color: cs.onSurface.withValues(alpha: 0.3),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: cs.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.category,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.color} · ${item.style}',
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: cs.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyleTips(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final tips = [
      '搭配遵循"三色原则"，全身颜色不超过三种更协调',
      '质感相近的面料搭配在一起更显高级',
      '上松下紧或上紧下松的廓形更显身材比例',
    ];

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                '穿搭小贴士',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tip,
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurface.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
