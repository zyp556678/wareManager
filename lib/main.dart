import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:amap_flutter_location_plus/amap_flutter_location_plus.dart';
import 'screens/home_screen.dart';
import 'screens/capture_screen.dart';
import 'screens/wardrobe_screen.dart';
import 'screens/profile_screen.dart';
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
    // 导航栏索引: 0=首页, 1=衣橱, 2=录入(路由), 3=我的
    if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const CaptureScreen()));
      return;
    }
    setState(() => _currentIndex = index);
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
      ProfileScreen(
        onNavigateToTab: setTabIndex,
        onNavigateToWardrobeTab: setWardrobeTab,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex > 2 ? _currentIndex - 1 : _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: GlassNavBar(
        currentIndex: _currentIndex,
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
            icon: Icons.person_outline,
            selectedIcon: Icons.person,
            label: '我的',
          ),
        ],
      ),
    );
  }
}
