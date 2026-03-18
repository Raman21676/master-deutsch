import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

void main() async {
  // Generate icons for different sizes
  final sizes = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
  };
  
  for (final entry in sizes.entries) {
    final size = entry.value;
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final paint = ui.Paint();
    
    // Create rounded rect path
    final rect = ui.Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble());
    final rrect = ui.RRect.fromRectAndRadius(rect, ui.Radius.circular(size * 0.2));
    
    // Clip to rounded rectangle
    canvas.clipRRect(rrect);
    
    // Draw black stripe (top)
    paint.color = ui.Color(0xFF000000);
    canvas.drawRect(ui.Rect.fromLTWH(0, 0, size.toDouble(), size / 3), paint);
    
    // Draw red stripe (middle)
    paint.color = ui.Color(0xFFFF0000);
    canvas.drawRect(ui.Rect.fromLTWH(0, size / 3, size.toDouble(), size / 3), paint);
    
    // Draw gold stripe (bottom)
    paint.color = ui.Color(0xFFFFCE00);
    canvas.drawRect(ui.Rect.fromLTWH(0, size * 2 / 3, size.toDouble(), size / 3), paint);
    
    // Convert to image
    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();
    
    // Save to file
    final file = File('android/app/src/main/res/${entry.key}/ic_launcher.png');
    await file.writeAsBytes(bytes);
    print('Generated ${entry.key} (${size}x$size)');
  }
  
  print('All icons generated!');
}
