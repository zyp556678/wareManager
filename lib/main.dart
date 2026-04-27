import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'screens/home_screen.dart';
import 'screens/capture_screen.dart';
import 'screens/wardrobe_screen.dart';
import 'screens/profile_screen.dart';
import 'providers/clothing_provider.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
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
}

class WearWiseApp extends StatelessWidget {
  const WearWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ClothingProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
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
  late PageController _pageController;
  final GlobalKey<WardrobeScreenState> _wardrobeKey = GlobalKey<WardrobeScreenState>();
  int? _pendingWardrobeTab;

  void setTabIndex(int index) {
    final navIndex = index > 1 ? index + 1 : index;
    _pageController.animateToPage(
      navIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentIndex = index;
    });
  }

  void setWardrobeTab(int tabIndex) {
    _pendingWardrobeTab = tabIndex;
    if (_currentIndex != 1) {
      setTabIndex(1);
    }
    Future.delayed(const Duration(milliseconds: 400), () {
      _wardrobeKey.currentState?.switchToTab(tabIndex);
      _pendingWardrobeTab = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  List<Widget> get _screens => [
    HomeScreen(onNavigateToTab: setTabIndex),
    WardrobeScreen(key: _wardrobeKey),
    ProfileScreen(onNavigateToTab: setTabIndex, onNavigateToWardrobeTab: setWardrobeTab),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          final navIndex = index < 2 ? index : index + 1;
          setState(() {
            _currentIndex = navIndex;
          });
          if (index == 1 && _pendingWardrobeTab != null) {
            Future.delayed(const Duration(milliseconds: 100), () {
              _wardrobeKey.currentState?.switchToTab(_pendingWardrobeTab!);
              _pendingWardrobeTab = null;
            });
          }
        },
        children: _screens,
      ),
      bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: NavigationBar(
              height: 72,
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CaptureScreen()),
                  );
                } else {
                  setTabIndex(index);
                }
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: colorScheme.primary.withValues(alpha: 0.1),
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined, color: Colors.grey[600]),
                  selectedIcon: Icon(Icons.home, color: colorScheme.primary),
                  label: '首页',
                ),
                NavigationDestination(
                  icon: Icon(Icons.checkroom_outlined, color: Colors.grey[600]),
                  selectedIcon: Icon(Icons.checkroom, color: colorScheme.primary),
                  label: '衣橱',
                ),
                NavigationDestination(
                  icon: Icon(Icons.add_circle_outline, color: Colors.grey[600]),
                  selectedIcon: Icon(Icons.add_circle, color: colorScheme.primary),
                  label: '录入',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline, color: Colors.grey[600]),
                  selectedIcon: Icon(Icons.person, color: colorScheme.primary),
                  label: '我的',
                ),
              ],
            ),
          ),
    );
  }
}