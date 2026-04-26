import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'recognition_confirm_page.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  final ImagePicker _picker = ImagePicker();
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;

    // App状态改变时处理相机
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

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

      // 使用后置摄像头
      final firstCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        firstCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      _initializeControllerFuture = _controller!.initialize();
      await _initializeControllerFuture;

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

  Future<void> _takePhoto() async {
    if (!_isCameraInitialized || _controller == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('相机未就绪')),
      );
      return;
    }

    try {
      await _initializeControllerFuture;

      final image = await _controller!.takePicture();

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RecognitionConfirmPage(imagePath: image.path),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('拍照失败: $e')),
        );
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
            builder: (_) => RecognitionConfirmPage(imagePath: image.path),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('录入衣物'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // 相机预览区域
          Container(
            color: Colors.black,
            child: _isCameraInitialized
                ? CameraPreview(_controller!)
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
                        const SizedBox(height: 16),
                        const Text(
                          '正在初始化相机...',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
          ),

          // 衣物轮廓辅助框
          Center(
            child: Container(
              width: 250,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.6),
                  width: 2,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: CustomPaint(
                painter: DashedBorderPainter(),
              ),
            ),
          ),

          // 顶部提示文字
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '将衣服平铺在纯色背景上拍照',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),

          // 底部控制按钮
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // 相册按钮
                IconButton(
                  icon: const Icon(
                    Icons.photo_library,
                    size: 32,
                    color: Colors.white,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                  ),
                  onPressed: _pickFromGallery,
                ),

                // 拍照按钮
                GestureDetector(
                  onTap: _takePhoto,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                // 占位，保持对称
                const SizedBox(width: 48),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 虚线边框绘制器
class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    const double dashWidth = 10;
    const double dashSpace = 5;

    // 绘制虚线矩形
    double startX = 0;
    while (startX < size.width) {
      final double endX = (startX + dashWidth).clamp(0.0, size.width);
      path.moveTo(startX, 0);
      path.lineTo(endX, 0);
      startX += dashWidth + dashSpace;
    }

    startX = 0;
    while (startX < size.width) {
      final double endX = (startX + dashWidth).clamp(0.0, size.width);
      path.moveTo(startX, size.height);
      path.lineTo(endX, size.height);
      startX += dashWidth + dashSpace;
    }

    double startY = 0;
    while (startY < size.height) {
      final double endY = (startY + dashWidth).clamp(0.0, size.height);
      path.moveTo(0, startY);
      path.lineTo(0, endY);
      startY += dashWidth + dashSpace;
    }

    startY = 0;
    while (startY < size.height) {
      final double endY = (startY + dashWidth).clamp(0.0, size.height);
      path.moveTo(size.width, startY);
      path.lineTo(size.width, endY);
      startY += dashWidth + dashSpace;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
