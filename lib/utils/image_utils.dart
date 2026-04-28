import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

Future<String> saveImageToAppDir(String tempPath) async {
  final appDir = await getApplicationDocumentsDirectory();
  final imageDir = Directory('${appDir.path}/images');
  if (!await imageDir.exists()) await imageDir.create(recursive: true);

  final ext = p.extension(tempPath);
  final fileName = '${DateTime.now().millisecondsSinceEpoch}$ext';
  final newPath = '${imageDir.path}/$fileName';

  await File(tempPath).copy(newPath);
  return newPath;
}
