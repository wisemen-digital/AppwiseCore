//
// AppwiseCore
// Copyright © 2024 Wisemen
//

// MARK: - Getters

public extension Result {
	/// Returns `true` if the result is a success, `false` otherwise.
	var isSuccess: Bool {
		switch self {
		case .success: return true
		case .failure: return false
		}
	}

	/// Returns `true` if the result is a failure, `false` otherwise.
	var isFailure: Bool {
		switch self {
		case .success: return false
		case .failure: return true
		}
	}

	/// Returns the associated value if the result is a success, `nil` otherwise.
	var value: Success? {
		switch self {
		case .success(let value): return value
		case .failure: return nil
		}
	}

	/// Returns the associated error value if the result is a failure, `nil` otherwise.
	var error: Failure? {
		switch self {
		case .success: return nil
		case .failure(let error): return error
		}
	}
}

// MARK: - Cancellation

@available(*, deprecated, renamed: "CancellationError", message: "Use the built-in cancellation type.")
public struct Cancelled: Error {}

public extension Result {
	/// Returns a new cancelled result.
	static var cancelled: Result<Success, Error> {
		if #available(iOS 13.0, *) {
			return .failure(CancellationError())
		} else {
			return .failure(Cancelled())
		}
	}

	/// Returns `true` if this result is cancelled.
	var isCancelled: Bool {
		if #available(iOS 13.0, *), case let .failure(error) = self, error is CancellationError {
			return true
		}

		switch self {
		case .failure(let error) where error is Cancelled: return true
		default: return false
		}
	}
}

// MARK: - Other

public extension Result {
	/// Convert success value to a `Void`
	func asVoid() -> Result<Void, Failure> {
		map { _ in }
	}

	/// Evaluates the specified closure when the `Result` is a success, passing the unwrapped value as a parameter.
	///
	/// Use the `withValue` function to evaluate the passed closure without modifying the `Result` instance.
	///
	/// - Parameter closure: A closure that takes the success value of this instance.
	/// - Returns: This `Result` instance, unmodified.
	@discardableResult
	func withValue(_ closure: (Success) throws -> Void) rethrows -> Result {
		if case .success(let value) = self { try closure(value) }
		return self
	}

	/// Evaluates the specified closure when the `Result` is a failure, passing the unwrapped error as a parameter.
	///
	/// Use the `withError` function to evaluate the passed closure without modifying the `Result` instance.
	///
	/// - Parameter closure: A closure that takes the success value of this instance.
	/// - Returns: This `Result` instance, unmodified.
	@discardableResult
	func withError(_ closure: (Failure) throws -> Void) rethrows -> Result {
		if case .failure(let error) = self { try closure(error) }
		return self
	}

	/// Evaluates the specified closure when the `Result` is a success.
	///
	/// Use the `ifSuccess` function to evaluate the passed closure without modifying the `Result` instance.
	///
	/// - Parameter closure: A `Void` closure.
	/// - Returns: This `Result` instance, unmodified.
	@discardableResult
	func ifSuccess(_ closure: () throws -> Void) rethrows -> Result {
		if isSuccess { try closure() }
		return self
	}

	/// Evaluates the specified closure when the `Result` is a failure.
	///
	/// Use the `ifFailure` function to evaluate the passed closure without modifying the `Result` instance.
	///
	/// - Parameter closure: A `Void` closure.
	/// - Returns: This `Result` instance, unmodified.
	@discardableResult
	func ifFailure(_ closure: () throws -> Void) rethrows -> Result {
		if isFailure { try closure() }
		return self
	}
}
