//
//  MainEventLoop.swift
//  WolfNIO
//
//  Created by Wolf McNally on 4/10/19.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
import NIO
import NIOTransportServices
import Dispatch

/// This is an NIO event loop that only dispatches its tasks on the main thread
/// (`DispatchQueue.main`).
public class MainEventLoop: QoSEventLoop {
    private init() { }

    /// The shared singleton `MainEventLoop`.
    public static let shared = MainEventLoop()

    public func execute(qos: DispatchQoS, _ task: @escaping () -> Void) {
        DispatchQueue.main.async(qos: qos, execute: task)
    }

    public var inEventLoop: Bool {
        return Thread.isMainThread
    }

    public func execute(_ task: @escaping () -> Void) {
        DispatchQueue.main.async(execute: task)
    }

    public func scheduleTask<T>(deadline: NIODeadline, _ task: @escaping () throws -> T) -> Scheduled<T> {
        return scheduleTask(deadline: deadline, qos: .default, task)
    }

    public func scheduleTask<T>(deadline: NIODeadline, qos: DispatchQoS, _ task: @escaping () throws -> T) -> Scheduled<T> {
        let p: EventLoopPromise<T> = self.makePromise()

        // Dispatch support for cancellation exists at the work-item level, so we explicitly create one here.
        // We set the QoS on this work item and explicitly enforce it when the block runs.
        let timerSource = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        timerSource.schedule(deadline: DispatchTime(uptimeNanoseconds: deadline.uptimeNanoseconds))
        timerSource.setEventHandler(qos: qos, flags: .enforceQoS) {
            do {
                p.succeed(try task())
            } catch {
                p.fail(error)
            }
        }
        timerSource.resume()

        return Scheduled(promise: p, cancellationTask: {
            timerSource.cancel()
        })
    }

    public func scheduleTask<T>(in time: TimeAmount, _ task: @escaping () throws -> T) -> Scheduled<T> {
        return self.scheduleTask(in: time, qos: .default, task)
    }

    public func scheduleTask<T>(in time: TimeAmount, qos: DispatchQoS, _ task: @escaping () throws -> T) -> Scheduled<T> {
        return self.scheduleTask(deadline: NIODeadline.now() + time, qos: qos, task)
    }

    public func shutdownGracefully(queue: DispatchQueue, _ callback: @escaping (Error?) -> Void) {
        fatalError("Attempt to shut down main event loop.")
    }
}
#endif
