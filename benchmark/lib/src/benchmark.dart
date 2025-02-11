import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

@internal
String formatDuration(Duration d) {
  final micros = d.inMicroseconds;
  if (micros < 1000) return '$micros µs';
  if (micros < 1000000) return '${(micros / 1000).toStringAsFixed(2)} ms';
  return '${(micros / 1000000).toStringAsFixed(2)} s';
}

List<Duration> benchmark(
  void Function() operation,
  int n, {

  /// Runs Once before all the iterations (including warmup)
  void Function()? setupAll,

  /// Runs once after all the iterations (including warmup)
  void Function()? cleanupAll,

  /// Runs before each iteration (including warmup)
  void Function()? setup,

  /// Runs after each iteration (including warmup)
  void Function()? cleanup,

  /// Warmup, if null, [operation] is used
  void Function()? warmup,
}) {
  final times = <Duration>[];

  setupAll?.call();

  warmup ??= operation;
  setup?.call();
  warmup();
  cleanup?.call();

  final stopwatch = Stopwatch();
  for (var i = 0; i < n; i++) {
    setup?.call();
    stopwatch.start();
    operation();

    stopwatch.stop();
    times.add(stopwatch.elapsed);
    stopwatch.reset();
    cleanup?.call();
  }

  cleanupAll?.call();

  return times;
}

void logDurationMetrics(
  List<Duration> durations, {
  required Logger logger,
  List<MetricBase> metrics = const [],
}) {
  if (durations.isEmpty) return;

  logger.info('Benchmark Results:');

  metrics
      .map((m) => m.reportShort(m.calculateInternal(durations)))
      .toList()
      .forEach(logger.info);
}

/// A base class for a metric, like average, min, max, etc.
abstract class MetricBase<V> {
  MetricBase(this.debugLabel);
  final String debugLabel;

  @visibleForOverriding
  @visibleForTesting
  V calculateInternal(List<Duration> durations);

  String reportShort(V value) => '$debugLabel: $value';
}

/// A metric that calculates the average of a list of durations.
class AverageMetric extends MetricBase<Duration> {
  AverageMetric() : super('Average');

  @override
  Duration calculateInternal(List<Duration> durations) {
    return durations.reduce((a, b) => a + b) ~/ durations.length;
  }

  @override
  String reportShort(Duration value) => 'average: ${formatDuration(value)}';
}

/// A metric that calculates the minimum of a list of durations.
class MinMetric extends MetricBase<Duration> {
  MinMetric() : super('Min');

  @override
  Duration calculateInternal(List<Duration> durations) {
    return durations.reduce((a, b) => a < b ? a : b);
  }

  @override
  String reportShort(Duration value) => 'min: ${formatDuration(value)}';
}

/// A metric that calculates the maximum of a list of durations.
class MaxMetric extends MetricBase<Duration> {
  MaxMetric() : super('Max');

  @override
  Duration calculateInternal(List<Duration> durations) {
    return durations.reduce((a, b) => a > b ? a : b);
  }

  @override
  String reportShort(Duration value) {
    return 'max: ${formatDuration(value)}';
  }
}
