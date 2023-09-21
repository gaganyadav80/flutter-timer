import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';

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
  Duration _duration = kDefaultDuration;
  TimerState _timerState = TimerState.stopped;
  int _sliderValue = kDefaultDuration.inMinutes;

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
    _lastUsedDuration = _duration;

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        setState(() {
          if (_duration.inSeconds == 0) {
            _cancelTimer(TimerState.completed);
          } else {
            _duration -= const Duration(seconds: 1);
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
      _duration = _lastUsedDuration;
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
                  final width = constraints.maxWidth.floor();

                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onHorizontalDragUpdate: (details) {
                      if (details.localPosition.dx > width + 20) {
                        return;
                      }
                      setState(() {
                        _sliderValue = ((details.localPosition.dx).clamp(0, width - 1) / 2).floor();
                        _duration = Duration(minutes: _sliderValue);
                      });
                    },
                    onTapDown: (details) {
                      setState(() {
                        _sliderValue = ((details.localPosition.dx).clamp(0, width - 1) / 2).floor();
                        _duration = Duration(minutes: _sliderValue);
                      });
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
                          left: _sliderValue.toDouble() * 2,
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
                      _duration = const Duration(minutes: 5);
                      _startTimer();
                    });
                  },
                ),
                const SizedBox(width: 16),
                _buildSuggestionButtons(
                  '15m',
                  () {
                    setState(() {
                      _duration = const Duration(minutes: 15);
                      _startTimer();
                    });
                  },
                ),
                const SizedBox(width: 16),
                _buildSuggestionButtons(
                  '25m',
                  () {
                    setState(() {
                      _duration = const Duration(minutes: 25);
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
                  child: () {
                    if (_timerState == TimerState.running) {
                      return 'stop';
                    }
                    return 'start';
                  }()
                      .text
                      .size(13)
                      .color(kForegroundColor)
                      .make(),
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
                _duration.formatToHHMMss().text.size(32).light.color(kForegroundColor).make(),
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
      child: time.text.size(13).color(kForegroundColor).make(),
      padding: EdgeInsets.zero,
      minSize: 0,
      onPressed: onTap,
    );
  }
}
