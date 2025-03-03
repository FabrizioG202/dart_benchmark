import 'dart:math' as math show sqrt;

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

/// Formats a [Duration] into a human-readable string.
/// with the given [fractionDigits].
@internal
String formatDuration(Duration d, {int fractionDigits = 2}) {
  return switch (d.inMicroseconds) {
    < 1000 => '${d.inMicroseconds} µs',
    < 1000000 =>
      '${(d.inMicroseconds / 1000).toStringAsFixed(fractionDigits)} ms',
    _ => '${(d.inMicroseconds / 1000000).toStringAsFixed(fractionDigits)} s',
  };
}

/// Benchmarks the execution time of an [operation].
///
/// The [operation] is executed [n] times, and the execution time of each
/// iteration is recorded. Optional [setupAll], [cleanupAll], [setup],
/// [cleanup], and [warmup] functions can be provided to further customize
/// the benchmarking process.
///
/// - [operation]: The function to benchmark.
/// - [n]: The number of times to execute the [operation].
///   Must be a positive integer.
/// - [setupAll]: A function that runs once before *all iterations* (including warmup).
/// - [cleanupAll]: A function that runs once after *all iterations* (including warmup).
/// - [setup]: A function that runs before each iteration* (including warmup).
/// - [cleanup]: A function that runs after each iteration (including warmup).
/// - [warmup]: A function to use for warmup; if `null`, [operation] is used,
///             to skip warmup, pass in an empty function.
List<Duration> benchmark(
  void Function() operation,
  int n, {
  void Function()? setupAll,
  void Function()? cleanupAll,
  void Function()? setup,
  void Function()? cleanup,
  void Function()? warmup,
}) {
  final times = <Duration>[];

  // global setup
  setupAll?.call();

  // warmup
  warmup ??= operation;
  {
    setup?.call();
    warmup();
    cleanup?.call();
  }

  // main measuring.
  final stopwatch = Stopwatch();
  for (var i = 0; i < n; i++) {
    // setup, then measure.
    setup?.call();
    stopwatch.start();
    operation();

    // stop, then cleanup.
    stopwatch.stop();
    times.add(stopwatch.elapsed);
    stopwatch.reset();
    cleanup?.call();
  }

  // global cleanup
  cleanupAll?.call();
  return times;
}

@Deprecated('Use `computeAllMetrics` instead')
void logDurationMetrics(
  List<Duration> durations, {
  required Logger logger,
  List<MetricBase> metrics = const [],
}) {
  if (durations.isEmpty) return;

  logger.info('Benchmark Results:');

  metrics
      .map((m) => m.reportShort(m.evaluate(durations)))
      .toList()
      .forEach(logger.info);
}

/// A utility that provides computation of metrics from durations.
List<X> evaluateAllMetrics<X>(
  List<Duration> durations,
  List<MetricBase<X>> metrics,
) {
  return metrics.map((m) {
    return m.evaluate(durations);
  }).toList();
}

/// A base class for a metric, like average, min, max, etc.
abstract class MetricBase<V> {
  MetricBase(this.debugLabel);
  final String debugLabel;

  V evaluate(List<Duration> durations);

  String reportShort(V value) => '$debugLabel: $value';
}

/// Arithmetic mean of a list of durations.
class DurationMeanMetric extends MetricBase<Duration> {
  DurationMeanMetric() : super('Average');

  @override
  Duration evaluate(List<Duration> durations) {
    return durations.reduce((a, b) => a + b) ~/ durations.length;
  }

  @override
  String reportShort(Duration value) => 'average: ${formatDuration(value)}';
}

/// Minimum of a list of durations.
class DurationMinMetric extends MetricBase<Duration> {
  DurationMinMetric() : super('Min');

  @override
  Duration evaluate(List<Duration> durations) {
    return durations.reduce((a, b) => a < b ? a : b);
  }

  @override
  String reportShort(Duration value) {
    return 'min: ${formatDuration(value)}';
  }
}

/// Maximum of a list of durations.
class DurationMaxMetric extends MetricBase<Duration> {
  DurationMaxMetric() : super('Max');

  @override
  Duration evaluate(List<Duration> durations) {
    return durations.reduce((a, b) => a > b ? a : b);
  }

  @override
  String reportShort(Duration value) {
    return 'max: ${formatDuration(value)}';
  }
}

/// Standard deviation of a list of durations.
class DurationStdDevMetric extends MetricBase<Duration> {
  DurationStdDevMetric() : super('StdDev');

  @override
  Duration evaluate(List<Duration> durations) {
    if (durations.isEmpty) return Duration.zero;

    final us = durations.map((d) => d.inMicroseconds).toList();
    final meanUs = us.reduce((a, b) => a + b) ~/ us.length;
    final sumOfSquares = us
        .map((d) => (d - meanUs) * (d - meanUs))
        .fold(0, (a, b) => a + b);
    return Duration(microseconds: math.sqrt(sumOfSquares ~/ us.length).round());
  }

  @override
  String reportShort(Duration value) {
    return 'stddev: ${formatDuration(value)}';
  }
}
