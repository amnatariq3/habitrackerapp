import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class TimerPage extends StatefulWidget {
  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> with SingleTickerProviderStateMixin {
  // Stopwatch
  Stopwatch _stopwatch = Stopwatch();
  Timer? _stopwatchTimer;

  // Countdown
  int _countdownSeconds = 10;
  Timer? _countdownTimer;

  // Interval
  int _workSeconds = 5;
  int _restSeconds = 3;
  bool _isWorkTime = true;
  int _currentIntervalTime = 5;
  Timer? _intervalTimer;

  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> _playSound() async {
    await _audioPlayer.play(AssetSource('beep.mp3'));
  }

  void _startStopwatch() {
    _stopwatch.start();
    _stopwatchTimer = Timer.periodic(Duration(milliseconds: 100), (_) => setState(() {}));
  }

  void _stopStopwatch() {
    _stopwatch.stop();
    _stopwatchTimer?.cancel();
  }

  void _resetStopwatch() {
    _stopwatch.reset();
    setState(() {});
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        if (_countdownSeconds > 0) {
          _countdownSeconds--;
        } else {
          _playSound();
          _stopCountdown();
        }
      });
    });
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
  }

  void _resetCountdown() {
    _countdownSeconds = 10;
    setState(() {});
  }

  void _startInterval() {
    _intervalTimer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        if (_currentIntervalTime > 0) {
          _currentIntervalTime--;
        } else {
          _playSound();
          _isWorkTime = !_isWorkTime;
          _currentIntervalTime = _isWorkTime ? _workSeconds : _restSeconds;
        }
      });
    });
  }

  void _stopInterval() {
    _intervalTimer?.cancel();
  }

  void _resetInterval() {
    _isWorkTime = true;
    _currentIntervalTime = _workSeconds;
    setState(() {});
  }

  @override
  void dispose() {
    _stopwatchTimer?.cancel();
    _countdownTimer?.cancel();
    _intervalTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
      final isDark = Theme
          .of(context)
          .brightness == Brightness.dark;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.grey[900],
          bottom: TabBar(
            tabs: [
              Tab(text: 'Stopwatch'),
              Tab(text: 'Countdown'),
              Tab(text: 'Interval'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildStopwatchTab(),
            _buildCountdownTab(),
            _buildIntervalTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildStopwatchTab() {
    final elapsed = _stopwatch.elapsed;
    final timeStr = '${elapsed.inMinutes.remainder(60).toString().padLeft(2, '0')}:${elapsed.inSeconds.remainder(60).toString().padLeft(2, '0')}:${(elapsed.inMilliseconds.remainder(1000) ~/ 100).toString()}';

    return _buildTimerUI(timeStr, _startStopwatch, _stopStopwatch, _resetStopwatch);
  }

  Widget _buildCountdownTab() {
    final timeStr = _countdownSeconds.toString().padLeft(2, '0');

    return _buildTimerUI(timeStr, _startCountdown, _stopCountdown, _resetCountdown);
  }

  Widget _buildIntervalTab() {
    final timeStr = _currentIntervalTime.toString().padLeft(2, '0');
    final status = _isWorkTime ? 'Work' : 'Rest';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('$status Time', style: TextStyle(color: Colors.white, fontSize: 24)),
        SizedBox(height: 20),
        Text(timeStr, style: TextStyle(color: Colors.white, fontSize: 64)),
        SizedBox(height: 40),
        _buildControlButtons(_startInterval, _stopInterval, _resetInterval),
      ],
    );
  }

  Widget _buildTimerUI(String timeStr, VoidCallback onStart, VoidCallback onStop, VoidCallback onReset) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(timeStr, style: TextStyle(color: Colors.white, fontSize: 64)),
        SizedBox(height: 40),
        _buildControlButtons(onStart, onStop, onReset),
      ],
    );
  }

  Widget _buildControlButtons(VoidCallback onStart, VoidCallback onStop, VoidCallback onReset) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(onPressed: onStart, child: Text('Start')),
        ElevatedButton(onPressed: onStop, child: Text('Stop')),
        ElevatedButton(onPressed: onReset, child: Text('Reset')),
      ],
    );
  }
}
