## 0.0.1

- Initial version.

## 0.1.0
- Fixed typos in Installation Instructions in README.
- Updated the logging example in the main function to create a dedicated logger and cancel its subscription.
- Updated roadmap items to clarify Async Support, Better Metrics, and Logging to File.

## 0.1.1
- Fixed the SDK constraint to be more permissive by using ">=3.7.0<4.0.0" instead of "^3.7.0-323.1.beta"
- Added a `computeAllMetrics` function to allow users to opt out of the logger-based printing.
- Updated README with a more in-depth example and clearer instructions.

## 0.2.0
- Renamed metrics classes to be more descriptive: `AverageMetric` → `DurationMeanMetric`, `MinMetric` → `DurationMinMetric`, and `MaxMetric` → `DurationMaxMetric`
- Added new `DurationStdDevMetric` for calculating standard deviation
- Added more comprehensive documentation for benchmark function parameters
- Improved `formatDuration` function with pattern matching using `switch` expressions
- Renamed `calculateInternal` method to `evaluate` for better API consistency, since it is no longer meant to be used only internally.
- Marked `logDurationMetrics` as deprecated in favor of `evaluateAllMetrics` (renamed from `computeAllMetrics`)
- Updated README with examples for creating custom metrics
- Added section about using import prefixes to avoid naming conflicts
- Updated example code to demonstrate the new metrics and custom metric creation