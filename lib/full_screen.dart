import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FullScreen extends StatefulWidget {
  const FullScreen({super.key, required this.image});
  final String image;

  @override
  State<FullScreen> createState() => _FullScreenState();
}

class _FullScreenState extends State<FullScreen> {
  static const platform = MethodChannel('wallpaper_channel');

  Future<void> setWallpaper() async {
    try {
      final result = await platform.invokeMethod('setWallpaper', {'url': widget.image});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.message}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Image.network(widget.image, fit: BoxFit.cover),
          ),
          InkWell(
            onTap: setWallpaper,
            child: Container(
              height: 60,
              width: double.infinity,
              color: Colors.black,
              child: const Center(
                child: Text(
                  'Set as Wallpaper',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
