import 'failure.dart';

/// Result type for handling success/failure cases
sealed class Result<T> {
  const Result();

  /// Creates a successful result
  factory Result.success(T data) = Success<T>;

  /// Creates a failed result
  factory Result.failure(Failure failure) = Fail<T>;

  /// Executes the appropriate callback based on the result type
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  });

  /// Returns true if this is a success result
  bool get isSuccess => this is Success<T>;

  /// Returns true if this is a failure result
  bool get isFailure => this is Fail<T>;

  /// Gets the data or null
  T? get dataOrNull => isSuccess ? (this as Success<T>).data : null;

  /// Gets the failure or null
  Failure? get failureOrNull => isFailure ? (this as Fail<T>).failure : null;
}

/// Success variant of Result
final class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    return onSuccess(data);
  }
}

/// Failure variant of Result
final class Fail<T> extends Result<T> {
  final Failure failure;

  const Fail(this.failure);

  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    return onFailure(failure);
  }
}