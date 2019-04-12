import UIKit
import WolfNIO
import PlaygroundSupport

/// The time this playground started running
let startTime = Date().timeIntervalSinceReferenceDate

/// The elapsed time since this playground started running
var elapsedTime: TimeInterval { return Date().timeIntervalSinceReferenceDate - startTime }

/// A variation of `print()` that prefixes its arguments with the elapsed time since this playground started running
/// (rounded to the nearest 10,000th of a second) and an indicator of whether it's running on the main thread
/// or a background thread.
func printLog(_ items: Any...) {
    let message = items.map({ String(describing: $0) }).joined()
    let time = (elapsedTime * 10_000).rounded() / 10_000
    let name = Thread.isMainThread ? "[main]" : "[background]"
    let prefix = [String(describing: time), name].filter({ !$0.isEmpty }).joined(separator: " ")
    print("\(prefix): \(message)")
}

/// Called at the start of a demo, tells the playground to run indefinitely (until `finish()` is called.)
func start() { PlaygroundPage.current.needsIndefiniteExecution = true }

/// Called at the end of a demo, tells the playground to finish execution.
func finish() { PlaygroundPage.current.finishExecution() }

func makeBackgroundEventLoopGroup(loopCount: Int) -> EventLoopGroup {
    return NIOTSEventLoopGroup(loopCount: loopCount, defaultQoS: .default)
}

/// This demo asynchronously mock-fetches three pieces of data (integers) and when all are present,
/// sums them and prints the result.
struct Demo1 {
    // We're going to perform the mock-fetches on a background `DispatchQueue` wrapped with an
    // `EventLoopGroup`. `EventLoopsGroup`s vend `EventLoops` from their `next()` call, which can
    // then be used to make `Promise`s.
    let backgroundEventLoopGroup = makeBackgroundEventLoopGroup(loopCount: 3)

    /// A function that performs a mock-fetch of an integer after a simulated
    /// period of latency.
    ///
    /// The fetch itself executes on a background thread, but the promise is
    /// fulfilled on the main thread. Notice that none of these calls (even the ones
    /// on the background thread) actually block.
    func mockFetch(returning value: Int, afterSeconds seconds: TimeInterval) -> Future<Int> {
        // Make the promise that will deliver the results of the fetch on the main event loop.
        let promise = MainEventLoop.shared.makePromise(of: Int.self)
        // Schedule the fetch on a background event loop.
        backgroundEventLoopGroup.next().scheduleTask(in: .milliseconds(TimeAmount.Value(seconds * 1000))) {
            // This executes later on a background thread, and fulfills the promise with the result.
            printLog("Fetched \(value)")
            promise.succeed(value)
        }
        // This executes immediately and returns the Future associated with the promise.
        return promise.futureResult
    }

    /// Runs the demo. Completes on the main thread.
    func run() -> Future<Void> {
        // Make the promise that will be fulfilled when the demo completes
        let promise = MainEventLoop.shared.makePromise(of: Void.self)

        // Kick off the fetching of our two integers. Note that these calls do
        // not block and return immediately.
        let future1 = mockFetch(returning: 2, afterSeconds: 1)
        let future2 = mockFetch(returning: 3, afterSeconds: 2)
        // Note this future kicks off third, but fulfills before the others.
        let future3 = mockFetch(returning: 5, afterSeconds: 0.5)

        // Register what to do when both futures have succeeded.
        // `whenAllSucceed` transforms an array of futures to an array of results.
        Future.whenAllSucceed([future1, future2, future3], on: MainEventLoop.shared).map {
            let sum = $0.reduce(0, +)
            printLog("Sum of fetched values: \(sum)")
            promise.succeed(())
        }

        return promise.futureResult
    }
}

start()
Demo1().run().always {
    printLog("Done!")
    finish()
}
