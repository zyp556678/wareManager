import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'photo_confirm_screen.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  final ImagePicker _picker = ImagePicker();
  bool _isCameraInitialized = false;
  bool _isRearCamera = true;
  FlashMode _flashMode = FlashMode.off;
  bool _isCapturing = false;

  late AnimationController _shutterAnimationController;
  late Animation<double> _shutterScaleAnimation;
  late AnimationController _focusAnimationController;
  late Animation<double> _focusAnimation;

  Offset? _focusPoint;
  bool _showFocusIndicator = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _shutterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _shutterScaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _shutterAnimationController, curve: Curves.easeInOut),
    );

    _focusAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _focusAnimation = Tween<double>(begin: 1.5, end: 0.0).animate(
      CurvedAnimation(parent: _focusAnimationController, curve: Curves.easeOut),
    );

    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _shutterAnimationController.dispose();
    _focusAnimationController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('未找到相机')),
          );
        }
        return;
      }

      final selectedCamera = cameras.firstWhere(
        (camera) =>
            camera.lensDirection ==
            (_isRearCamera ? CameraLensDirection.back : CameraLensDirection.front),
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        selectedCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;

      if (_flashMode != FlashMode.off) {
        await _controller!.setFlashMode(_flashMode);
      }

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('相机初始化失败: $e')),
        );
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_controller == null) return;

    setState(() {
      _isRearCamera = !_isRearCamera;
    });

    await _controller?.dispose();
    _controller = null;
    setState(() {
      _isCameraInitialized = false;
    });

    await _initializeCamera();
  }

  Future<void> _toggleFlash() async {
    if (_controller == null || !_isCameraInitialized) return;

    FlashMode newMode;
    switch (_flashMode) {
      case FlashMode.off:
        newMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        newMode = FlashMode.always;
        break;
      default:
        newMode = FlashMode.off;
    }

    try {
      await _controller!.setFlashMode(newMode);
      setState(() {
        _flashMode = newMode;
      });
    } catch (e) {
      debugPrint('闪光灯切换失败: $e');
    }
  }

  void _onTapToFocus(TapDownDetails details) {
    if (_controller == null || !_isCameraInitialized) return;

    final size = MediaQuery.of(context).size;
    final x = details.localPosition.dx / size.width;
    final y = details.localPosition.dy / size.height;

    setState(() {
      _focusPoint = details.localPosition;
      _showFocusIndicator = true;
    });

    _focusAnimationController.reset();
    _focusAnimationController.forward();

    _controller!.setFocusPoint(Offset(x, y));
    _controller!.setExposurePoint(Offset(x, y));
  }

  Future<void> _takePhoto() async {
    if (!_isCameraInitialized || _controller == null || _isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    _shutterAnimationController.forward();
    HapticFeedback.mediumImpact();

    if (_flashMode == FlashMode.always) {
      await _controller!.setFlashMode(FlashMode.always);
    }

    try {
      await _initializeControllerFuture;
      final image = await _controller!.takePicture();

      await _shutterAnimationController.reverse();

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PhotoConfirmScreen(imagePath: image.path),
        ),
      );
    } catch (e) {
      await _shutterAnimationController.reverse();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('拍照失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
      );

      if (image != null && mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PhotoConfirmScreen(imagePath: image.path),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('选择图片失败: $e')),
        );
      }
    }
  }

  IconData _getFlashIcon() {
    switch (_flashMode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      default:
        return Icons.flash_off;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onTapDown: _onTapToFocus,
            child: _isCameraInitialized && _controller != null
                ? ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.center,
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height:
                              MediaQuery.of(context).size.width *
                              _controller!.value.aspectRatio,
                          child: CameraPreview(_controller!),
                        ),
                      ),
                    ),
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          '正在初始化相机...',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
          ),

          if (_showFocusIndicator && _focusPoint != null)
            Positioned(
              left: _focusPoint!.dx - 30,
              top: _focusPoint!.dy - 30,
              child: AnimatedBuilder(
                animation: _focusAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _focusAnimation.value.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: 1.5 - _focusAnimation.value,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 8,
                right: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTopButton(
                    icon: Icons.close,
                    onTap: () => Navigator.pop(context),
                  ),
                  Row(
                    children: [
                      _buildTopButton(
                        icon: _getFlashIcon(),
                        onTap: _toggleFlash,
                      ),
                      const SizedBox(width: 12),
                      _buildTopButton(
                        icon: Icons.cameraswitch,
                        onTap: _switchCamera,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 24,
                top: 100,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    colorScheme.surface.withValues(alpha: 0.9),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSideButton(
                    icon: Icons.photo_library,
                    onTap: _pickFromGallery,
                  ),
                  _buildShutterButton(colorScheme),
                  _buildSideButton(
                    icon: Icons.cameraswitch,
                    onTap: _switchCamera,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildSideButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildShutterButton(ColorScheme colorScheme) {
    return GestureDetector(
      onTap: _isCameraInitialized && !_isCapturing ? _takePhoto : null,
      child: AnimatedBuilder(
        animation: _shutterScaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _shutterScaleAnimation.value,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isCameraInitialized
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.4),
                  width: 4,
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: _isCameraInitialized
                      ? colorScheme.primary
                      : Colors.white.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}