import NIO

// MARK: Global

extension Future {
    /// Statically available method for mimicking behavior of calling `return future.map` where no starting future is available.
    ///
    ///     return Future.map(on: req) {
    ///         return try someThrowingThing()
    ///     }
    ///
    /// This allows you to convert any non-throwing, future-return method into a closure that accepts throwing and returns a future.
    public static func map(on worker: EventLoopGroup, _ callback: @escaping () throws -> Expectation) -> Future<Expectation> {
        let promise = worker.eventLoop.newPromise(Expectation.self)

        do {
            try promise.succeed(callback())
        } catch {
            promise.fail(error)
        }

        return promise.futureResult
    }

    /// Statically available method for mimicking behavior of calling `return future.flatMap` where no starting future is available.
    ///
    ///     return Future.flatMap(on: req) {
    ///         return try someAsyncThrowingThing()
    ///     }
    ///
    /// This allows you to convert any non-throwing, future-return method into a closure that accepts throwing and returns a future.
    public static func flatMap(on worker: EventLoopGroup, _ callback: @escaping () throws -> Future<Expectation>) -> Future<Expectation> {
        let promise = worker.eventLoop.newPromise(Expectation.self)

        do {
            try callback().cascade(to: promise)
        } catch {
            promise.fail(error)
        }

        return promise.futureResult
    }
}
