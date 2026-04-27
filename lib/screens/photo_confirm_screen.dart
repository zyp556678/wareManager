import 'dart:io';
import 'package:flutter/material.dart';
import 'recognition_confirm_page.dart';

class PhotoConfirmScreen extends StatefulWidget {
  final String imagePath;

  const PhotoConfirmScreen({super.key, required this.imagePath});

  @override
  State<PhotoConfirmScreen> createState() => _PhotoConfirmScreenState();
}

class _PhotoConfirmScreenState extends State<PhotoConfirmScreen> {
  void _onRetake() {
    Navigator.pop(context);
  }

  void _onConfirm() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RecognitionConfirmPage(imagePath: widget.imagePath),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Image.file(
              File(widget.imagePath),
              fit: BoxFit.contain,
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
                  GestureDetector(
                    onTap: _onRetake,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  GestureDetector(
                    onTap: _onConfirm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Text(
                        '使用照片',
                        style: TextStyle(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
                top: 80,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    label: '重拍',
                    icon: Icons.refresh,
                    onTap: _onRetake,
                    isPrimary: false,
                  ),
                  _buildActionButton(
                    label: '使用照片',
                    icon: Icons.check,
                    onTap: _onConfirm,
                    isPrimary: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isPrimary) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: [
              Icon(icon, color: colorScheme.onPrimary, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}