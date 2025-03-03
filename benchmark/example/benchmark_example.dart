import 'package:benchmark/benchmark.dart';
import 'package:logging/logging.dart';

// Recursive Fibonacci implementation (intentionally inefficient)
int fibRecursive(int n) {
  if (n <= 1) return n;
  return fibRecursive(n - 1) + fibRecursive(n - 2);
}

// Iterative Fibonacci implementation (more efficient)
int fibIterative(int n) {
  if (n <= 1) return n;
  var prev = 0;
  var current = 1;
  for (var i = 2; i <= n; i++) {
    final next = prev + current;
    prev = current;
    current = next;
  }
  return current;
}

void main() {
  // Set up logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) => print(record.message));
  final logger = Logger('FibonacciBenchmark');

  final metrics = [
    // Common metrics to use
    DurationMeanMetric(),
    DurationMinMetric(),
    DurationMaxMetric(),
    DurationStdDevMetric(),

    // Our metrics
    MyDurationMeanMetric(),
  ];

  // Benchmark recursive implementation
  final recursiveTimes = benchmark(() => fibRecursive(32), 10);

  logger.info('Recursive Fibonacci(32):');
  for (var m in metrics) {
    logger.info(m.reportShort(m.evaluate(recursiveTimes)));
  }

  // Benchmark iterative implementation
  final iterativeTimes = benchmark(() => fibIterative(32), 10);

  logger.info('\nIterative Fibonacci(32):');
  for (var m in metrics) {
    logger.info(m.reportShort(m.evaluate(iterativeTimes)));
  }
}

/// An example on how to override [DurationMeanMetric] to make it print
/// in a different format
class MyDurationMeanMetric extends DurationMeanMetric {
  @override
  String reportShort(Duration value) => 'My mean: ${value.inMicroseconds} μs';
}
