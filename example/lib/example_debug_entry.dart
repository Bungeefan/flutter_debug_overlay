import 'package:flutter/material.dart';
import 'package:flutter_debug_overlay/flutter_debug_overlay.dart';

class ExampleDebug extends StatelessWidget {
  final void Function([ThemeMode? themeMode]) onThemeChange;

  const ExampleDebug({super.key, required this.onThemeChange});

  @override
  Widget build(BuildContext context) {
    return DebugEntry(
      title: const Text("Example"),
      child: Column(
        children: [
          ListTile(
            title: Text(
              "Theme Mode",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: OutlinedButton(
              onPressed: onThemeChange,
              child: const Text("Reset"),
            ),
          ),
          ListTile(
            title: Text(
              "Force Theme Mode",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 32),
              child: ToggleButtons(
                onPressed: (index) async {
                  switch (index) {
                    case 0:
                      onThemeChange(ThemeMode.light);
                      break;
                    case 1:
                      onThemeChange(ThemeMode.dark);
                      break;
                  }
                },
                isSelected: const [false, false],
                borderRadius: BorderRadius.circular(20),
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: Text("Light"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: Text("Dark"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
