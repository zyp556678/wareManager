import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:amap_flutter_location_plus/amap_flutter_location_plus.dart';
import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_gemma_litertlm/flutter_gemma_litertlm.dart';
import 'package:flutter_gemma_mediapipe/flutter_gemma_mediapipe.dart';
import 'screens/home_screen.dart';
import 'screens/capture_screen.dart';
import 'screens/wardrobe_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/ai_chat_screen.dart';
import 'providers/clothing_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/weather_provider.dart';

import 'widgets/glass_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化高德定位隐私合规
  AMapFlutterLocation.updatePrivacyShow(true, true);
  AMapFlutterLocation.updatePrivacyAgree(true);
  AMapFlutterLocation.setApiKey('be44cd468bf141674cc696c89cc7c07e', '');

  // 初始化 FlutterGemma AI 引擎
  await FlutterGemma.initialize(
    inferenceEngines: const [LiteRtLmEngine(), MediaPipeEngine()],
  );

  await _requestPermissions();

  runApp(const WearWiseApp());
}

Future<void> _requestPermissions() async {
  final cameraStatus = await Permission.camera.request();
  if (cameraStatus.isDenied) {
    debugPrint('相机权限被拒绝');
  }
  
  final storageStatus = await Permission.storage.request();
  if (storageStatus.isDenied) {
    debugPrint('存储权限被拒绝');
  }
  
  final photosStatus = await Permission.photos.request();
  if (photosStatus.isDenied) {
    debugPrint('照片权限被拒绝');
  }
  
  final locationStatus = await Permission.location.request();
  if (locationStatus.isDenied) {
    debugPrint('定位权限被拒绝');
  }
}

class WearWiseApp extends StatelessWidget {
  const WearWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ClothingProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()..loadFromPrefs()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: '穿戴管家',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: const Locale('zh', 'CN'),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('zh', 'CN'),
              Locale('en', 'US'),
            ],
            home: const MainScreen(),
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final GlobalKey<WardrobeScreenState> _wardrobeKey = GlobalKey<WardrobeScreenState>();
  late final List<Widget> _screens;

  void setTabIndex(int index) {
    // 导航栏索引: 0=首页, 1=衣橱, 2=录入(路由), 3=AI, 4=我的
    if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CaptureScreen()));
      return;
    }
    // 转换导航索引到页面索引: 0→0, 1→1, 3→2, 4→3
    final screenIndex = index > 2 ? index - 1 : index;
    setState(() => _currentIndex = screenIndex);
  }

  void setWardrobeTab(int tabIndex) {
    setState(() => _currentIndex = 1);
    _wardrobeKey.currentState?.switchToTab(tabIndex);
  }

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(
        onNavigateToTab: setTabIndex,
        onNavigateToWardrobeTab: setWardrobeTab,
      ),
      WardrobeScreen(key: _wardrobeKey),
      const AiChatScreen(),
      ProfileScreen(
        onNavigateToTab: setTabIndex,
        onNavigateToWardrobeTab: setWardrobeTab,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final hasBackground = themeProvider.backgroundEnabled &&
            themeProvider.backgroundPath != null;

        final scaffold = Scaffold(
          backgroundColor: hasBackground
              ? Theme.of(context).colorScheme.surface.withValues(alpha: themeProvider.backgroundOpacity)
              : null,
          body: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
        );

        // 页面索引转导航索引: 0→0, 1→1, 2→3, 3→4
        final navIndex = _currentIndex >= 2 ? _currentIndex + 1 : _currentIndex;

        final navBar = Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: GlassNavBar(
            currentIndex: navIndex,
            onTap: (index) {
              if (index == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CaptureScreen()),
                );
              } else {
                setTabIndex(index);
              }
            },
            items: const [
              NavBarItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: '首页',
              ),
              NavBarItem(
                icon: Icons.checkroom_outlined,
                selectedIcon: Icons.checkroom,
                label: '衣橱',
              ),
              NavBarItem(
                icon: Icons.add_circle_outline,
                selectedIcon: Icons.add_circle,
                label: '录入',
              ),
              NavBarItem(
                icon: Icons.auto_awesome_outlined,
                selectedIcon: Icons.auto_awesome,
                label: 'AI',
              ),
              NavBarItem(
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                label: '我的',
              ),
            ],
          ),
        );

        if (!hasBackground) {
          return Stack(children: [scaffold, navBar]);
        }

        return Stack(
          children: [
            Positioned.fill(
              child: Image.file(
                File(themeProvider.backgroundPath!),
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
            scaffold,
            navBar,
          ],
        );
      },
    );
  }
}
