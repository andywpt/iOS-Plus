import Combine
import UIKit

extension UIControl {
    struct Publisher<T>: Combine.Publisher where T: UIControl {
        typealias Output = T
        typealias Failure = Never

        private unowned var control: T
        private let event: T.Event

        init(control: T, for event: T.Event) {
            self.control = control
            self.event = event
        }

        func receive<S>(subscriber: S) where S: Subscriber, S.Input == Output, S.Failure == Failure {
            let subscription = Subscription(subscriber: subscriber, control: control, event: event)
            subscriber.receive(subscription: subscription)
        }

        private final class Subscription<S>: Combine.Subscription where S: Subscriber, S.Input == Output, S.Failure == Failure {
            // keep a strong reference to the subscriber so that it can send it values
            private var subscriber: S?
            private weak var control: T?
            private let event: T.Event

            init(subscriber: S, control: T, event: T.Event) {
                self.subscriber = subscriber
                self.control = control
                self.event = event
                control.addTarget(self, action: #selector(eventTriggered), for: event)
            }

            deinit {
                finish()
            }

            // Our UIControl publisher doesn't respond to back pressure from the viewModel (i.e flatmap with maxPublisher won't work)
            func request(_: Subscribers.Demand) {}

            func cancel() {
                finish()
            }

            private func finish() {
                control?.removeTarget(self, action: #selector(eventTriggered), for: event)
                control = nil
                subscriber = nil
            }

            @objc func eventTriggered() {
                guard let control else { return }
                _ = subscriber?.receive(control)
            }
        }
    }
}

// Adapted from https://www.apeth.com/UnderstandingCombine/publishers/publisherscustom.html
// Since we cannot say Self in a class extension, we have to do a tricky little dance:
// Declare a protocol, make the class adopt that protocol, and inject the method using an extension on the protocol, where the term Self is legal.

protocol UIControlWithPublisher: UIControl {}
extension UIControl: UIControlWithPublisher {}

extension UIControlWithPublisher {
    func publisher(for event: UIControl.Event = .primaryActionTriggered) -> UIControl.Publisher<Self> {
        .init(control: self, for: event)
    }
}
