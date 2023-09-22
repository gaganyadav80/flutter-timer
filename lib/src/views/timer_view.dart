import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../utils/utils_barrel.dart';
import '../widgets/vertical_time_slider.dart';

class TimerView extends StatefulWidget {
  const TimerView({super.key});

  @override
  State<TimerView> createState() => _TimerViewState();
}

class _TimerViewState extends State<TimerView> {
  Timer? _timer;
  Duration _lastUsedDuration = kDefaultDuration;
  Duration _currentDuration = kDefaultDuration;
  TimerState _timerState = TimerState.stopped;
  double _sliderPosition = kDefaultDuration.inMinutes.toDouble();

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

    setState(() {
      _timerState = TimerState.running;
    });
    _lastUsedDuration = _currentDuration;

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        setState(() {
          if (_currentDuration.inSeconds == 0) {
            _cancelTimer(TimerState.completed);
          } else {
            _currentDuration -= const Duration(seconds: 1);
          }
        });
      },
    );
  }

  void _cancelTimer(TimerState state) {
    setState(() {
      _timerState = state;
      _handleAudioPlayback();
      _timer?.cancel();
      _currentDuration = _lastUsedDuration;
    });
  }

  void _handleAudioPlayback() {
    if (_player.state == PlayerState.playing) {
      _player.stop();
      return;
    }
    if (_timerState == TimerState.completed) {
      _player.play(_playerAssetSource);
    }
  }

  void _handleSliderChange(double localPosition, double sliderWidth) {
    setState(() {
      var position = localPosition.clamp(0, sliderWidth).toDouble();
      position = (position / 2).round() * 2;
      var durationInMinutes = (position / sliderWidth) * kMaxDuration.inMinutes;

      if (position > 0) {
        _sliderPosition = position.clamp(0, position - 2);
      } else {
        _sliderPosition = position.clamp(0, position);
      }
      _currentDuration = Duration(
        minutes: durationInMinutes.toInt(),
      );
    });
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
                  final sliderWidth = constraints.maxWidth;

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragUpdate: (DragUpdateDetails details) {
                      final localPosition = details.localPosition.dx;
                      // Returning this method with a buffer of 20px because `_handleSliderChange` calls `setState`.
                      // And we do not want to call setState when user is out of slider's interactive area.
                      if (localPosition > sliderWidth + 20) {
                        return;
                      }
                      _handleSliderChange(localPosition, sliderWidth);
                    },
                    onTapDown: (TapDownDetails details) {
                      final localPosition = details.localPosition.dx;
                      _handleSliderChange(localPosition, sliderWidth);
                    },
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Slider Base
                        const IgnorePointer(
                          child: VerticalTimeSlider(),
                        ),
                        // Indicator
                        Positioned(
                          left: _sliderPosition,
                          child: Container(
                            height: kSliderHeight,
                            width: kActiveSliderWidth,
                            color: kForegroundColor,
                          ),
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
                    setState(() {
                      _currentDuration = const Duration(minutes: 5);
                      _startTimer();
                    });
                  },
                ),
                const SizedBox(width: 16),
                _buildSuggestionButtons(
                  '15m',
                  () {
                    setState(() {
                      _currentDuration = const Duration(minutes: 15);
                      _startTimer();
                    });
                  },
                ),
                const SizedBox(width: 16),
                _buildSuggestionButtons(
                  '25m',
                  () {
                    setState(() {
                      _currentDuration = const Duration(minutes: 25);
                      _startTimer();
                    });
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
                  child: Text(
                    _timerState == TimerState.running ? 'stop' : 'start',
                    style: const TextStyle(
                      fontSize: 13,
                      color: kForegroundColor,
                    ),
                  ),
                  padding: EdgeInsets.zero,
                  minSize: 0,
                  onPressed: () async {
                    if (_timerState == TimerState.running) {
                      _cancelTimer(TimerState.stopped);
                    } else {
                      _startTimer();
                    }
                  },
                ),
                const Spacer(),
                Text(
                  _currentDuration.formatToHHMMss(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w300,
                    color: kForegroundColor,
                  ),
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
