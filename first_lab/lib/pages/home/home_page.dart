import 'package:first_lab/modules/counter/counter_module.dart';
import 'package:first_lab/shared/styles/app_text_styles.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({required this.title, super.key});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final CounterModule _counter = CounterModule();

  void _increment() => setState(_counter.increment);
  void _reset() => setState(_counter.reset);

  double get _progress => _counter.hasUnlockedImage
      ? 1
      : _counter.counter / CounterModule.unlockThreshold;

  Color _getAuraColor(ColorScheme colors) {
    if (_counter.hasUnlockedImage) return colors.tertiary;

    final stage = _counter.counter % CounterModule.stageImagePaths.length;
    if (stage == 0) return colors.primary;
    if (stage == 1) return colors.secondary;
    return colors.inversePrimary;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final activeImage = _counter.activeImagePath;
    final auraColor = _getAuraColor(colors);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.inversePrimary,
        title: Text(widget.title, style: AppTextStyles.tertiaryHeader),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                key: const Key('counter_image'),
                onTap: _reset,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        auraColor.withValues(alpha: 0.25),
                        colors.surface,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: auraColor.withValues(alpha: 0.35),
                        blurRadius: 24,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      switchInCurve: Curves.easeOutBack,
                      switchOutCurve: Curves.easeInCubic,
                      child: Image.asset(
                        activeImage,
                        key: ValueKey(_counter.changeVersion),
                        width: 220,
                        height: 220,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Counter:',
                style: textTheme.bodyMedium ?? AppTextStyles.counterLabel,
              ),
              Text(
                '${_counter.counter}',
                key: const Key('counter_value'),
                style: textTheme.headlineMedium ?? AppTextStyles.counterValue,
              ),
              const SizedBox(height: 8),
              Text(
                _counter.stageLabel,
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(value: _progress, minHeight: 10),
              ),
              const SizedBox(height: 8),
              Text(
                _counter.hasUnlockedImage
                    ? 'Threshold reached. The fourth image is active.'
                    : 'Remaining to threshold 20: ${_counter.pointsToUnlock}.',
                key: const Key('unlock_status'),
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _counter.hasUnlockedImage
                    ? 'State locked: the fourth image stays active.'
                    : 'When value is below 20, 3 images rotate in a loop.',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _increment,
        tooltip: 'Increment',
        elevation: 0,
        highlightElevation: 0,
        child: const Icon(Icons.add),
      ),
    );
  }
}
