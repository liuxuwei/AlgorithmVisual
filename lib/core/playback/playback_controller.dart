import 'dart:async';
import 'package:flutter/foundation.dart';
import '../scene/scene_frame.dart';

/// 帧播放控制器
///
/// 继承 ValueNotifier, 当前帧变化时自动通知监听者 (ValueListenableBuilder)
class PlaybackController extends ValueNotifier<SceneFrame> {
  final List<SceneFrame> _frames;
  int _currentIndex;
  double _speed = 1.0;
  bool _isPlaying = false;
  bool _loop = false;
  Timer? _timer;

  PlaybackController(this._frames)
      : _currentIndex = 0,
        super(_frames.isEmpty
            ? throw ArgumentError('frames must not be empty')
            : _frames[0]);

  /// 当前帧序号
  int get currentIndex => _currentIndex;

  /// 总帧数
  int get frameCount => _frames.length;

  /// 当前播放速度
  double get speed => _speed;

  /// 是否正在播放
  bool get isPlaying => _isPlaying;

  /// 是否循环模式
  bool get loop => _loop;

  /// 当前帧
  SceneFrame get currentFrame => value;

  /// 末帧索引
  int get lastIndex => _frames.length - 1;

  /// 设置播放速度
  void setSpeed(double newSpeed) {
    _speed = newSpeed;
    if (_isPlaying) {
      _restartTimer();
    }
  }

  /// 设置循环模式
  void setLoop(bool enabled) {
    _loop = enabled;
  }

  /// 播放
  void play() {
    if (_frames.isEmpty) return;
    if (_currentIndex >= lastIndex && !_loop) {
      _currentIndex = 0;
      _updateValue();
    }
    _isPlaying = true;
    _restartTimer();
  }

  /// 暂停
  void pause() {
    _isPlaying = false;
    _timer?.cancel();
    _timer = null;
  }

  /// 播放/暂停切换
  void togglePlay() {
    if (_isPlaying) {
      pause();
    } else {
      play();
    }
  }

  /// 前进一帧
  void stepForward() {
    if (_currentIndex < lastIndex) {
      _currentIndex++;
      _updateValue();
    } else if (_loop) {
      _currentIndex = 0;
      _updateValue();
    }
  }

  /// 后退一帧
  void stepBackward() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _updateValue();
    }
  }

  /// 跳到指定帧 (clamp 到有效范围)
  void seek(int index) {
    _currentIndex = index.clamp(0, lastIndex);
    _updateValue();
  }

  /// 从头开始
  void restart() {
    pause();
    _currentIndex = 0;
    _updateValue();
  }

  void _restartTimer() {
    _timer?.cancel();
    // speed 越大, interval 越小
    final intervalMs = (500 / _speed).round();
    _timer = Timer.periodic(Duration(milliseconds: intervalMs), (_) {
      if (_currentIndex < lastIndex) {
        _currentIndex++;
        _updateValue();
      } else if (_loop) {
        _currentIndex = 0;
        _updateValue();
      } else {
        pause();
      }
    });
  }

  void _updateValue() {
    value = _frames[_currentIndex];
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
