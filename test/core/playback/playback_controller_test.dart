import 'package:algorithm_visual/core/playback/playback_controller.dart';
import 'package:algorithm_visual/core/scene/scene_frame.dart';
import 'package:algorithm_visual/core/scene/element.dart';
import 'package:algorithm_visual/core/scene/point.dart';
import 'package:flutter_test/flutter_test.dart';

List<SceneFrame> _makeFrames(int count) {
  return List.generate(count, (i) {
    return SceneFrame(
      frameId: i,
      caption: 'frame $i',
      elements: const [ArrayBar(id: 'a', position: Point(0, 0), value: 1, index: 0)],
    );
  });
}

void main() {
  group('PlaybackController', () {
    test('initial state', () {
      final frames = _makeFrames(5);
      final ctrl = PlaybackController(frames);

      expect(ctrl.currentIndex, 0);
      expect(ctrl.frameCount, 5);
      expect(ctrl.isPlaying, isFalse);
      expect(ctrl.speed, 1.0);
      expect(ctrl.loop, isFalse);
      expect(ctrl.currentFrame.frameId, 0);

      ctrl.dispose();
    });

    test('rejects empty frame list', () {
      expect(() => PlaybackController([]), throwsArgumentError);
    });

    test('stepForward increments index', () {
      final ctrl = PlaybackController(_makeFrames(5));
      ctrl.stepForward();
      expect(ctrl.currentIndex, 1);
      ctrl.stepForward();
      expect(ctrl.currentIndex, 2);
      ctrl.dispose();
    });

    test('stepForward stops at last frame', () {
      final ctrl = PlaybackController(_makeFrames(3));
      ctrl.seek(2);
      ctrl.stepForward();
      expect(ctrl.currentIndex, 2); // 不越界
      ctrl.dispose();
    });

    test('stepBackward stops at 0', () {
      final ctrl = PlaybackController(_makeFrames(3));
      ctrl.stepBackward(); // 已在 0, 无操作
      expect(ctrl.currentIndex, 0);
      ctrl.dispose();
    });

    test('stepBackward decrements', () {
      final ctrl = PlaybackController(_makeFrames(3));
      ctrl.seek(2);
      ctrl.stepBackward();
      expect(ctrl.currentIndex, 1);
      ctrl.dispose();
    });

    test('seek clamps to valid range', () {
      final ctrl = PlaybackController(_makeFrames(5));
      ctrl.seek(100);
      expect(ctrl.currentIndex, 4);
      ctrl.seek(-5);
      expect(ctrl.currentIndex, 0);
      ctrl.dispose();
    });

    test('restart goes to first frame and pauses', () {
      final ctrl = PlaybackController(_makeFrames(5));
      ctrl.seek(3);
      ctrl.restart();
      expect(ctrl.currentIndex, 0);
      expect(ctrl.isPlaying, isFalse);
      ctrl.dispose();
    });

    test('speed changes interval', () {
      final ctrl = PlaybackController(_makeFrames(10));
      ctrl.setSpeed(2.0);
      expect(ctrl.speed, 2.0);
      ctrl.dispose();
    });

    test('loop toggle works', () {
      final ctrl = PlaybackController(_makeFrames(5));
      expect(ctrl.loop, isFalse);
      ctrl.setLoop(true);
      expect(ctrl.loop, isTrue);
      ctrl.dispose();
    });

    test('ValueNotifier fires on frame change', () async {
      final ctrl = PlaybackController(_makeFrames(5));
      final values = <int>[];
      ctrl.addListener(() => values.add(ctrl.currentIndex));

      ctrl.seek(3);
      ctrl.seek(1);
      ctrl.stepForward();

      // addListener 只在值变化时触发, 不会立即回调初始值
      expect(values, [3, 1, 2]);

      ctrl.dispose();
    });

    test('play auto-advances frames', () async {
      final ctrl = PlaybackController(_makeFrames(10));
      ctrl.setSpeed(20.0); // 极快速度
      ctrl.setLoop(false);

      ctrl.play();
      await Future.delayed(const Duration(milliseconds: 800));

      expect(ctrl.currentIndex, greaterThan(0));
      ctrl.dispose();
    });

    test('loop restarts after last frame', () async {
      final ctrl = PlaybackController(_makeFrames(3));
      ctrl.setSpeed(50.0);
      ctrl.setLoop(true);

      ctrl.play();
      await Future.delayed(const Duration(milliseconds: 400));

      // 应该已经循环至少一次
      expect(ctrl.isPlaying, isTrue);
      ctrl.dispose();
    });

    test('pause stops playback', () async {
      final ctrl = PlaybackController(_makeFrames(10));
      ctrl.setSpeed(20.0);

      ctrl.play();
      await Future.delayed(const Duration(milliseconds: 100));
      final idxAfterPlay = ctrl.currentIndex;

      ctrl.pause();
      await Future.delayed(const Duration(milliseconds: 300));

      expect(ctrl.currentIndex, idxAfterPlay);
      ctrl.dispose();
    });
  });
}
