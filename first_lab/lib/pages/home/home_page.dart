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
  final CounterModule _counterModule = CounterModule();

  void _incrementCounter() {
    setState(_counterModule.increment);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title, style: AppTextStyles.tertiaryHeader),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'You have pushed the button this many times:',
              style: textTheme.bodyMedium ?? AppTextStyles.counterLabel,
            ),
            Text(
              '${_counterModule.counter}',
              style: textTheme.headlineMedium ?? AppTextStyles.counterValue,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        elevation: 0,
        highlightElevation: 0,
        child: const Icon(Icons.add),
      ),
    );
  }
}
