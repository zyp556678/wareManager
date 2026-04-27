import 'dart:ui';
import 'package:flutter/material.dart';
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
          final navIndex = index < 2 ? index : index + 1;
          setState(() {
            _currentIndex = navIndex;
          });
        },
        children: _screens,
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CaptureScreen()),
                  );
                } else {
                  final targetIndex = index > 2 ? index - 1 : index;
                  setState(() {
                    _currentIndex = index;
                  });
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
              backgroundColor: Colors.transparent,
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
        ),
      ),
    );
  }
}