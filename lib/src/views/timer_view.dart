import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/providers.dart';
import '../utils/constants.dart';
import '../utils/enums.dart';
import '../utils/extensions.dart';
import '../widgets/vertical_time_slider.dart';

class TimerView extends ConsumerStatefulWidget {
  const TimerView({super.key});

  @override
  ConsumerState<TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends ConsumerState<TimerView> {
  Timer? _timer;
  Duration _lastUsedDuration = kDefaultDuration;
  double _sliderWidth = 0;

  final _player = AudioPlayer();
  final _playerAssetSource = AssetSource('sounds/wrist-watch-beep.mp3');

  @override
  void initState() {
    super.initState();
    _player.onPlayerStateChanged.listen((event) {
      // Keep playing the audio until manually stopped.
      if (event == PlayerState.completed) {
        _player.resume();
      }
    });
  }

  @override
  void dispose() {
    _cancelTimer(TimerState.stopped);
    super.dispose();
  }

  Future<void> _startTimer() async {
    if (_timer?.isActive ?? false) {
      _timer?.cancel();
    }
    ref.read(timerStateProvider.notifier).state = TimerState.running;

    _timer = Timer.periodic(
      1.toSeconds(),
      (timer) {
        if (ref.read(currentDurationProvider).inSeconds == 0) {
          _cancelTimer(TimerState.completed);
        } else {
          ref.read(currentDurationProvider.notifier).update((duration) => duration - 1.toSeconds());
        }
      },
    );
  }

  void _handleAudioPlayback() {
    if (_player.state == PlayerState.playing) {
      _player.stop();
      return;
    }
    if (ref.read(timerStateProvider) == TimerState.completed) {
      _player.play(_playerAssetSource);
    }
  }

  void _cancelTimer(TimerState timerState) {
    ref.read(timerStateProvider.notifier).state = timerState;
    _handleAudioPlayback();
    _timer?.cancel();
    _handleDurationChange(_lastUsedDuration);
  }

  void _handleSliderChange(double localPosition, double sliderWidth) {
    var position = localPosition.clamp(0, sliderWidth).toDouble();
    position = (position / 2).round() * 2;
    var durationInMinutes = (position / sliderWidth) * kMaxDuration.inMinutes;

    ref.read(sliderPositionProvider.notifier).state = position.clamp(
      0,
      position >= 2 ? position - 2 : position,
    );

    ref.read(currentDurationProvider.notifier).state = durationInMinutes.toMinutes();
  }

  void _handleDurationChange(Duration duration) {
    var durationInMinutes = duration.inMinutes.clamp(0, kMaxDuration.inMinutes);
    var sliderPosition = (durationInMinutes / kMaxDuration.inMinutes) * _sliderWidth;

    sliderPosition = (sliderPosition / 2).round() * 2;
    sliderPosition = sliderPosition.clamp(
      0,
      sliderPosition >= 2 ? sliderPosition - 2 : sliderPosition,
    );

    _lastUsedDuration = duration;
    ref.read(sliderPositionProvider.notifier).state = sliderPosition;
    ref.read(currentDurationProvider.notifier).state = duration;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: <Widget>[
            SizedBox(
              // For safety only
              height: kSliderHeight,
              child: LayoutBuilder(
                builder: (_, constraints) {
                  _sliderWidth = constraints.maxWidth;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragUpdate: (DragUpdateDetails details) {
                      final localPosition = details.localPosition.dx;
                      // Returning this method with a buffer of 20px because we do not want to update the widgets
                      // when user is out of slider's interactive area.
                      if (localPosition > _sliderWidth + 20) {
                        return;
                      }
                      _handleSliderChange(localPosition, _sliderWidth);
                    },
                    onTapDown: (TapDownDetails details) {
                      final localPosition = details.localPosition.dx;
                      _handleSliderChange(localPosition, _sliderWidth);
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Slider Base
                        const IgnorePointer(
                          child: VerticalTimeSlider(),
                        ),
                        // Indicator
                        Consumer(
                          builder: (_, ref, __) {
                            final sliderPosition = ref.watch(sliderPositionProvider);
                            return Positioned(
                              left: sliderPosition,
                              child: Container(
                                height: kSliderHeight,
                                width: kActiveSliderWidth,
                                color: kForegroundColor,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildSuggestionButtons(
                  '5m',
                  () {
                    _startTimer();
                    _handleDurationChange(5.toMinutes());
                  },
                ),
                const SizedBox(width: 16),
                _buildSuggestionButtons(
                  '15m',
                  () {
                    _startTimer();
                    _handleDurationChange(15.toMinutes());
                  },
                ),
                const SizedBox(width: 16),
                _buildSuggestionButtons(
                  '25m',
                  () {
                    _startTimer();
                    _handleDurationChange(25.toMinutes());
                  },
                ),
                const Spacer(),
                CupertinoButton(
                  child: const Icon(
                    CupertinoIcons.ellipsis,
                    size: 12,
                    color: Color(0xFF9DA3A7),
                  ),
                  minSize: 0,
                  padding: EdgeInsets.zero,
                  onPressed: () {},
                ),
              ],
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CupertinoButton(
                  child: Consumer(
                    builder: (_, ref, __) {
                      final timerState = ref.watch(timerStateProvider);
                      return Text(
                        timerState == TimerState.running ? 'stop' : 'start',
                        style: const TextStyle(
                          fontSize: 13,
                          color: kForegroundColor,
                        ),
                      );
                    },
                  ),
                  padding: EdgeInsets.zero,
                  minSize: 0,
                  onPressed: () async {
                    if (ref.read(timerStateProvider.notifier).state == TimerState.running) {
                      _cancelTimer(TimerState.stopped);
                    } else {
                      _startTimer();
                    }
                  },
                ),
                const Spacer(),
                Consumer(
                  builder: (_, ref, __) {
                    final currentDuration = ref.watch(currentDurationProvider);
                    return Text(
                      currentDuration.formatToHHMMss(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w300,
                        color: kForegroundColor,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  CupertinoButton _buildSuggestionButtons(
    String time,
    VoidCallback onTap,
  ) {
    return CupertinoButton(
      child: Text(
        time,
        style: const TextStyle(
          fontSize: 13,
          color: kForegroundColor,
        ),
      ),
      padding: EdgeInsets.zero,
      minSize: 0,
      onPressed: onTap,
    );
  }
}
