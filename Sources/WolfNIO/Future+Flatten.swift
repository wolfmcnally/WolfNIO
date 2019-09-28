import NIO

extension EventLoopGroup {
    /// See `BasicWorker`.
    public var eventLoop: EventLoop {
        return next()
    }

    /// Creates a new, succeeded `Future` from the worker's event loop with a `Void` value.
    ///
    ///    let a: Future<Void> = req.future()
    ///
    /// - returns: The succeeded future.
    public func future() -> Future<Void> {
        return self.eventLoop.makeSucceededFuture(())
    }

    /// Creates a new, succeeded `Future` from the worker's event loop.
    ///
    ///    let a: Future<String> = req.future("hello")
    ///
    /// - parameters:
    ///     - value: The value that the future will wrap.
    /// - returns: The succeeded future.
    public func future<T>(_ value: T) -> Future<T> {
        return self.eventLoop.makeSucceededFuture(value)
    }

    /// Creates a new, failed `Future` from the worker's event loop.
    ///
    ///    let b: Future<String> = req.future(error: Abort(...))
    ///
    /// - parameters:
    ///    - error: The error that the future will wrap.
    /// - returns: The failed future.
    public func future<T>(error: Error) -> Future<T> {
        return self.eventLoop.makeFailedFuture(error)
    }
}

// MARK: Flatten

/// A closure that returns a future.
public typealias LazyFuture<T> = () throws -> Future<T>

extension Collection {
    /// Flattens an array of lazy futures into a future with an array of results.
    /// - note: each subsequent future will wait for the previous to complete before starting.
    public func syncFlatten<T>(on worker: EventLoopGroup) -> Future<[T]> where Element == LazyFuture<T> {
        let promise = worker.eventLoop.newPromise([T].self)

        var elements: [T] = []
        elements.reserveCapacity(self.count)

        var iterator = makeIterator()
        func handle(_ future: LazyFuture<T>) {
            do {
                try future().do { res in
                    elements.append(res)
                    if let next = iterator.next() {
                        handle(next)
                    } else {
                        promise.succeed(elements)
                    }
                }.catch { error in
                    promise.fail(error)
                }
            } catch {
                promise.fail(error)
            }
        }

        if let first = iterator.next() {
            handle(first)
        } else {
            promise.succeed(elements)
        }

        return promise.futureResult
    }
}

extension Collection where Element == LazyFuture<Void> {
    /// Flattens an array of lazy void futures into a single void future.
    /// - note: each subsequent future will wait for the previous to complete before starting.
    public func syncFlatten(on worker: EventLoopGroup) -> Future<Void> {
        let flatten: Future<[Void]> = self.syncFlatten(on: worker)
        return flatten.transform(to: ())
    }
}

extension Collection {
    /// Flattens an array of futures into a future with an array of results.
    /// - note: the order of the results will match the order of the futures in the input array.
    public func flatten<T>(on worker: EventLoopGroup) -> Future<[T]> where Element == Future<T> {
        return Future.whenAllSucceed(Array(self), on: worker.eventLoop)
    }
}

extension Collection where Element == Future<Void> {
    /// Flattens an array of void futures into a single one.
    public func flatten(on worker: EventLoopGroup) -> Future<Void> {
        return Future.andAllSucceed(Array(self), on: worker.eventLoop)
    }
}
