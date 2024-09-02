import Combine
import UIKit

extension UIGestureRecognizer {
    struct Publisher<T>: Combine.Publisher where T: UIGestureRecognizer {
        typealias Output = T
        typealias Failure = Never

        unowned let control: T

        init(control: T) {
            self.control = control
        }

        func receive<S>(subscriber: S) where S: Subscriber, S.Input == Output, S.Failure == Failure {
            let subscription = Subscription(subscriber: subscriber, sender: control)
            subscriber.receive(subscription: subscription)
        }

        private class Subscription<S>: Combine.Subscription where S: Subscriber, S.Input == Output, S.Failure == Failure {
            weak var gesture: T?
            var subscriber: S?
            init(subscriber: S, sender: T) {
                self.subscriber = subscriber
                gesture = sender
                gesture?.addTarget(self, action: #selector(doAction))
            }

            func request(_: Subscribers.Demand) {}

            @objc func doAction(_: UIGestureRecognizer) {
                guard let sender = gesture else { return }
                _ = subscriber?.receive(sender)
            }

            private func finish() {
                gesture?.removeTarget(self, action: #selector(doAction))
                gesture = nil
                subscriber = nil
            }

            func cancel() {
                finish()
            }

            deinit {
                finish()
            }
        }
    }
}

protocol UIGestureRecognizerWithPublisher: UIGestureRecognizer {}
extension UIGestureRecognizer: UIGestureRecognizerWithPublisher {}

extension UIGestureRecognizerWithPublisher {
    var publisher: UIGestureRecognizer.Publisher<Self> {
        .init(control: self)
    }
}
