import NIO

extension Promise where Value == Void {
    /// Calls `succeed(())`.
    public func succeed() {
        self.succeed(())
    }
}

extension Future where Value == Void {
    /// A pre-completed `Future<Void>`.
    public static func done(on worker: EventLoopGroup) -> Future<Value> {
        let promise = worker.eventLoop.newPromise(Void.self)
        promise.succeed()
        return promise.futureResult
    }
}
