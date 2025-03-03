import 'dart:async';

import 'package:benchmark/src/benchmark.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

void main() {
  group('benchmark function', () {
    test('returns correct number of measurements', () {
      final times = benchmark(() {}, 5);
      expect(times.length, equals(5));
    });

    test('handles setup and cleanup including warmup', () {
      var setupCalled = 0;
      var cleanupCalled = 0;

      benchmark(
        () {},
        3,
        setup: () => setupCalled++,
        cleanup: () => cleanupCalled++,
      );

      expect(setupCalled, equals(4 /* 3 runs + warmup */));
      expect(cleanupCalled, equals(4 /* 3 runs + warmup */));
    });

    test('handles setupAll and cleanupAll', () {
      var setupAllCalled = 0;
      var cleanupAllCalled = 0;

      benchmark(
        () {},
        3,
        setupAll: () => setupAllCalled++,
        cleanupAll: () => cleanupAllCalled++,
      );

      expect(setupAllCalled, equals(1));
      expect(cleanupAllCalled, equals(1));
    });

    test('handles warmup correctly', () {
      var warmupCalled = 0;
      var operationCalled = 0;

      benchmark(() => operationCalled++, 3, warmup: () => warmupCalled++);

      expect(warmupCalled, equals(1));
      expect(operationCalled, equals(3));
    });

    test('uses operation as warmup when warmup is null', () {
      var operationCalled = 0;

      benchmark(() => operationCalled++, 3);

      expect(operationCalled, equals(4)); // 3 runs + 1 warmup
    });

    test('handles zero iterations', () {
      final times = benchmark(() {}, 0);
      expect(times, isEmpty);
    });
  });

  group('metrics', () {
    final durations = [
      Duration(microseconds: 100),
      Duration(microseconds: 200),
      Duration(microseconds: 300),
    ];

    test('AverageMetric calculates correct average', () {
      final metric = DurationMeanMetric();
      final result = metric.evaluate(durations);
      expect(result, equals(Duration(microseconds: 200)));
    });

    test('MinMetric finds minimum duration', () {
      final metric = DurationMinMetric();
      final result = metric.evaluate(durations);
      expect(result, equals(Duration(microseconds: 100)));
    });

    test('MaxMetric finds maximum duration', () {
      final metric = DurationMaxMetric();
      final result = metric.evaluate(durations);
      expect(result, equals(Duration(microseconds: 300)));
    });

    test('metrics handle empty duration list', () {
      final emptyDurations = <Duration>[];
      final metrics = [
        DurationMeanMetric(),
        DurationMinMetric(),
        DurationMaxMetric(),
      ];

      for (final metric in metrics) {
        expect(() => metric.evaluate(emptyDurations), throwsStateError);
      }
    });

    test('metrics handle single duration', () {
      final singleDuration = [Duration(microseconds: 100)];

      expect(
        DurationMeanMetric().evaluate(singleDuration),
        equals(Duration(microseconds: 100)),
      );
      expect(
        DurationMinMetric().evaluate(singleDuration),
        equals(Duration(microseconds: 100)),
      );
      expect(
        DurationMaxMetric().evaluate(singleDuration),
        equals(Duration(microseconds: 100)),
      );
    });
  });

  group('formatDuration', () {
    test('formats microseconds correctly', () {
      expect(formatDuration(Duration(microseconds: 500)), equals('500 µs'));
    });

    test('formats milliseconds correctly', () {
      expect(formatDuration(Duration(microseconds: 1500)), equals('1.50 ms'));
    });

    test('formats seconds correctly', () {
      expect(formatDuration(Duration(microseconds: 1500000)), equals('1.50 s'));
    });

    test('handles zero duration', () {
      expect(formatDuration(Duration.zero), equals('0 µs'));
    });

    test('handles large durations', () {
      expect(formatDuration(Duration(microseconds: 5000000)), equals('5.00 s'));
    });
  });

  group('logDurationMetrics', () {
    late List<String> logMessages;
    late Logger logger;
    late StreamSubscription loggerSubscription;

    setUp(() {
      logMessages = [];
      logger = Logger('TestLogger');
      loggerSubscription = logger.onRecord.listen(
        (record) => logMessages.add(record.message),
      );
    });

    tearDown(() async {
      await loggerSubscription.cancel();
    });

    test('logs all metrics', () {
      final durations = [
        Duration(microseconds: 100),
        Duration(microseconds: 200),
      ];

      logDurationMetrics(
        durations,
        logger: logger,
        metrics: [
          DurationMeanMetric(),
          DurationMinMetric(),
          DurationMaxMetric(),
        ],
      );

      expect(logMessages, hasLength(4)); // Header + 3 metrics
      expect(logMessages.first, contains('Benchmark Results'));
      expect(
        logMessages.where((msg) => msg.contains('average:')),
        hasLength(1),
      );
      expect(logMessages.where((msg) => msg.contains('min:')), hasLength(1));
      expect(logMessages.where((msg) => msg.contains('max:')), hasLength(1));
    });

    test('handles empty metrics list', () {
      final durations = [Duration(microseconds: 100)];

      logDurationMetrics(durations, logger: logger, metrics: []);

      expect(logMessages, hasLength(1)); // Just header
      expect(logMessages.first, contains('Benchmark Results'));
    });

    test('handles empty durations list', () {
      logDurationMetrics(
        [],
        logger: logger,
        metrics: [
          DurationMeanMetric(),
          DurationMinMetric(),
          DurationMaxMetric(),
        ],
      );

      expect(logMessages, isEmpty);
    });

    test('metric report format is correct', () {
      final duration = Duration(microseconds: 1500);
      final metric = DurationMeanMetric();

      expect(metric.reportShort(duration), equals('average: 1.50 ms'));
    });
  });
}
