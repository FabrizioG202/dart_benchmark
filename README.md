# Benchmark Utility for Dart.

Minimal, highly customizable benchmarking utility for Dart.

## Why?

I am aware that different implementations of benchmarking utilities in dart already exists, such as `benchmarking_harness`. However, I needed an utility which was flexible especially in the reporting of the metrics and run count.

## Features

- Measure execution time of Dart functions
- Extremely easy-to-use setup and reporting (no classes required)
- Built-in warmup and setup phases
- Multiple metric types (average, min, max), with the possibility of implementing your own (example coming soon).

## Installation

For now, this package is not available on pub, but I intend to publish it in the near future. For this reason, this package can only be depended on using git dependencies. To do this, add the following to your `pubspec.yaml`:

```yaml
dependencies:
    benchmark: 
      git:
        url: https://github.com/FabrizioG202/dart_benchmark.git
        path: benchmark
```

Then run:

```bash
dart pub get
```

## Simple Example

```dart
import 'package:benchmark/benchmark.dart';
import 'package:logging/logging.dart';

// Recursive Fibonacci implementation (intentionally inefficient)
int fibRecursive(int n) {
  if (n <= 1) return n;
  return fibRecursive(n - 1) + fibRecursive(n - 2);
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
  ];

  // Benchmark recursive implementation
  final recursiveTimes = benchmark(() => fibRecursive(32), 10);

  logger.info('Recursive Fibonacci(32):');
  for (var m in metrics) {
    logger.info(m.reportShort(m.evaluate(recursiveTimes)));
  }
}
```

This will output something like:
```
Recursive Fibonacci(32):
mean: 2.54 ms
min: 2.31 ms
max: 2.89 ms
std dev: 0.15 ms
```

## Creating Custom Metrics

You can create custom metrics by extending any of the existing metric classes. Here's an example of creating a custom mean metric with a different reporting format:

```dart
/// An example on how to override [DurationMeanMetric] to make it print
/// in a different format
class MyDurationMeanMetric extends DurationMeanMetric {
  @override
  String reportShort(Duration value) => 'My mean: ${value.inMicroseconds} μs';
}

// Usage:
final metrics = [
  DurationMeanMetric(),
  MyDurationMeanMetric(),
];
```

This will output your custom formatted metric along with the standard ones.

## Import Prefixes

Since this package provides several global functions, it might be better to import it using a prefix to avoid naming conflicts:

```dart
import 'package:benchmark/benchmark.dart' as bench;

void main() {
  // Use the benchmark function with prefix
  final recursiveTimes = bench.benchmark(() => fibRecursive(32), 10);
  
  // Use other functions with prefix
  bench.logDurationMetrics(recursiveTimes, logger: logger, metrics: metrics);
}
```

## Roadmap
- [ ] More default metrics.
- [ ] Performance Comparisons.
- [ ] Custom Precision in Duration Formatting.
- [ ] Async Support (Support for asynchronous functions)
- [ ] Better Metrics (Standard Deviation, etc.)
- [ ] Logging to File. 

## License

This project is licensed under the MIT License.
