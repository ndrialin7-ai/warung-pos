import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data.dart';
import 'screens.dart';

void main() => runApp(
      ChangeNotifierProvider(create: (_) => PosState(), child: const WarungApp()),
    );

class WarungApp extends StatelessWidget {
  const WarungApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Warung Kopi Batam',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF6D4C41), // coklat kopi
          inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
          // Target sentuh minimal 48dp (Hukum Fitts)
          filledButtonTheme: FilledButtonThemeData(
            style: FilledButton.styleFrom(minimumSize: const Size(64, 52)),
          ),
        ),
        // Di layar lebar (laptop) aplikasi dibungkus bingkai HP
        builder: (context, child) => PhoneFrame(child: child!),
        home: const SplashScreen(),
      );
}

/// Bingkai HP untuk preview di laptop/Chrome. Di HP asli bingkai ini tidak muncul.
class PhoneFrame extends StatefulWidget {
  final Widget child;
  const PhoneFrame({super.key, required this.child});
  @override
  State<PhoneFrame> createState() => _PhoneFrameState();
}

class _PhoneFrameState extends State<PhoneFrame> {
  bool landscape = false;

  bool get _desktop =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    if (!_desktop || mq.size.width < 900) return widget.child;

    final w = landscape ? 860.0 : 400.0;
    final h = landscape ? 400.0 : 820.0;
    return Material(
      color: const Color(0xFF37474F),
      child: Stack(children: [
        Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              width: w + 24,
              height: h + 24,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(40),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: MediaQuery(
                  data: mq.copyWith(
                    size: Size(w, h),
                    padding: EdgeInsets.zero,
                    viewPadding: EdgeInsets.zero,
                    viewInsets: EdgeInsets.zero,
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: FilledButton.icon(
            icon: const Icon(Icons.screen_rotation),
            label: Text(landscape ? 'Portrait' : 'Putar layar (Landscape)'),
            onPressed: () => setState(() => landscape = !landscape),
          ),
        ),
      ]),
    );
  }
}