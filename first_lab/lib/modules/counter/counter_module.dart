class CounterModule {
  static const int unlockThreshold = 20;
  static const List<String> stageImagePaths = <String>[
    'assets/images/counter_stage_1.jpg',
    'assets/images/counter_stage_2.jpg',
    'assets/images/counter_stage_3.jpg',
  ];
  static const String unlockedImagePath = 'assets/images/counter_stage_4.jpg';

  int _counter = 0;
  int _changeVersion = 0;

  int get counter => _counter;
  int get changeVersion => _changeVersion;

  bool get hasUnlockedImage => _counter >= unlockThreshold;

  int get pointsToUnlock {
    final remaining = unlockThreshold - _counter;
    return remaining > 0 ? remaining : 0;
  }

  String get activeImagePath {
    if (hasUnlockedImage) {
      return unlockedImagePath;
    }

    return stageImagePaths[_counter % stageImagePaths.length];
  }

  String get stageLabel {
    if (hasUnlockedImage) {
      return 'Threshold reached. The fourth image is active.';
    }

    final currentIndex = (_counter % stageImagePaths.length) + 1;
    return 'Current stage: $currentIndex of ${stageImagePaths.length}.';
  }

  void increment() {
    _counter += 1;
    _changeVersion += 1;
  }

  void reset() {
    _counter = 0;
    _changeVersion += 1;
  }
}
