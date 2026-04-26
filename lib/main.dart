import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/home_screen.dart';
import 'screens/capture_screen.dart';
import 'screens/wardrobe_screen.dart';
import 'screens/profile_screen.dart';
import 'providers/clothing_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 请求相机和存储权限
  await _requestPermissions();
  
  runApp(const WearWiseApp());
}

Future<void> _requestPermissions() async {
  // 请求相机权限
  final cameraStatus = await Permission.camera.request();
  if (cameraStatus.isDenied) {
    debugPrint('相机权限被拒绝');
  }
  
  // 请求存储权限（Android 13以下）
  final storageStatus = await Permission.storage.request();
  if (storageStatus.isDenied) {
    debugPrint('存储权限被拒绝');
  }
  
  // Android 13+ 需要照片权限
  final photosStatus = await Permission.photos.request();
  if (photosStatus.isDenied) {
    debugPrint('照片权限被拒绝');
  }
}

class WearWiseApp extends StatelessWidget {
  const WearWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ClothingProvider()),
      ],
      child: MaterialApp(
        title: '穿戴管家',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          // 自定义配色方案
          colorScheme: ColorScheme.light(
            primary: const Color(0xFF7DD3FC),      // 主色：低饱和天蓝色
            secondary: const Color(0xFFE0F2FE),    // 辅助色：主色浅版
            surface: const Color(0xFFF0F9FF),      // 中性背景：淡蓝白
            background: const Color(0xFFF0F9FF),   // 背景色
            onPrimary: const Color(0xFF1F2937),    // 主色上的文字（深灰黑）
            onSecondary: const Color(0xFF1F2937),  // 辅助色上的文字
            onSurface: const Color(0xFF1F2937),    // 表面上的文字（文字主色）
            onBackground: const Color(0xFF1F2937), // 背景上的文字
            primaryContainer: const Color(0xFFE0F2FE),  // 主色容器
            onPrimaryContainer: const Color(0xFF1F2937), // 主色容器上的文字
            surfaceContainerHighest: const Color(0xFFE0F2FE), // 最高层容器
          ),
          // 文字主题
          textTheme: const TextTheme(
            displayLarge: TextStyle(color: Color(0xFF1F2937)),
            displayMedium: TextStyle(color: Color(0xFF1F2937)),
            displaySmall: TextStyle(color: Color(0xFF1F2937)),
            headlineLarge: TextStyle(color: Color(0xFF1F2937)),
            headlineMedium: TextStyle(color: Color(0xFF1F2937)),
            headlineSmall: TextStyle(color: Color(0xFF1F2937)),
            titleLarge: TextStyle(color: Color(0xFF1F2937)),
            titleMedium: TextStyle(color: Color(0xFF1F2937)),
            titleSmall: TextStyle(color: Color(0xFF1F2937)),
            bodyLarge: TextStyle(color: Color(0xFF1F2937)),
            bodyMedium: TextStyle(color: Color(0xFF1F2937)),
            bodySmall: TextStyle(color: Color(0xFF6B7280)),  // 文字次级：中灰
            labelLarge: TextStyle(color: Color(0xFF1F2937)),
            labelMedium: TextStyle(color: Color(0xFF1F2937)),
            labelSmall: TextStyle(color: Color(0xFF6B7280)),  // 文字次级：中灰
          ),
          appBarTheme: AppBarTheme(
            centerTitle: true,
            elevation: 0,
            backgroundColor: const Color(0xFFF0F9FF),
            foregroundColor: const Color(0xFF1F2937),
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7DD3FC),
              foregroundColor: const Color(0xFF1F2937),
              elevation: 0,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFE0F2FE),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  final List<Widget> _screens = const [
    HomeScreen(),
    WardrobeScreen(),
    ProfileScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          // 调整索引：PageView的索引0,1,2对应底部导航的0,1,3（跳过2-录入）
          final navIndex = index < 2 ? index : index + 1;
          setState(() {
            _currentIndex = navIndex;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 2) {
              // 点击录入按钮，打开相机页面
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CaptureScreen()),
              );
            } else {
              // 调整索引：如果点击的是"我的"(原索引3)，实际应该跳转到索引2
              final targetIndex = index > 2 ? index - 1 : index;
              setState(() {
                _currentIndex = index;
              });
              // 使用平滑动画切换到对应页面
              _pageController.animateToPage(
                targetIndex,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: '首页',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.checkroom_outlined),
              activeIcon: Icon(Icons.checkroom),
              label: '衣橱',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt_outlined),
              activeIcon: Icon(Icons.camera_alt),
              label: '录入',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: '我的',
            ),
          ],
        ),
      ),
    );
  }
}
