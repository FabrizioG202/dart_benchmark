# Benchmark Utility for Dart.

Bare-minimum, highly customizable benchmarking utility for Dart.

## Why?

I am aware that different implementations of benchmarking utilities in dart already exists, such as `benchmarking_harness`. However, I needed an utility which was customizable especially in the reporting of the metrics and run count.

## Features

- Measure execution time of Dart functions
- Extremely easy-to-use setup and reporting (no classes required)
- Built-in warmup and setup phases
- Multiple metric types (average, min, max), with the possibility of implementing your own (example coming soon).

## Installation

Add the package to your `pubspec.yaml`, for now this is not available on pub, but I intend of publishing it in the near future. For this reason, this package can only be depended on using git dependencies.

```yaml
dependencies:
    benchmark: 
        git: https://github.com/FabrizioG202/dart_benchmark.git
        path: benchmark
```

Then run:

```bash
dart pub get
```

## Simple Example

```dart
void main()
{
  // Set up logging
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) => print(record.message));
  final logger = Logger('FibonacciBenchmark');

  // Run the Benchmark
  final times = benchmark(() => fibRecursive(32), 10);

  // Log Results
  logDurationMetrics(times, logger: logger, metrics: metrics);
}
```

This will output something like:
```
Benchmark Results:
average: 2.54 ms
min: 2.31 ms
max: 2.89 ms
```

## Roadmap
- [ ] More default metrics.
- [ ] Performance Comparisons.
- [ ] Custom Precision in Duration Formatting.
- [ ] Async Support.

## License

This project is licensed under the MIT License.
