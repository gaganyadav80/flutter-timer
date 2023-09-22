import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/constants.dart';
import '../utils/enums.dart';

final timerStateProvider = StateProvider.autoDispose<TimerState>((Ref ref) => TimerState.stopped);
final currentDurationProvider = StateProvider.autoDispose<Duration>((Ref ref) => kDefaultDuration);
final sliderPositionProvider = StateProvider.autoDispose<double>((Ref ref) => kDefaultDuration.inMinutes.toDouble());
