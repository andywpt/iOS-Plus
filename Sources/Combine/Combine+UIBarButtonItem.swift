import Combine
import UIKit

extension UIBarButtonItem {
    struct Publisher<T>: Combine.Publisher where T: UIBarButtonItem {
        typealias Output = T
        typealias Failure = Never

        let barButtonItem: T

        init(barButtonItem: T) {
            self.barButtonItem = barButtonItem
        }

        func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Failure, S.Input == Output {
            let subscription = Subscription(subscriber: subscriber, barButtonItem: barButtonItem)
            subscriber.receive(subscription: subscription)
        }

        private class Subscription<S: Subscriber, Input: UIBarButtonItem>: Combine.Subscription where S.Input == Input {
            private var subscriber: S?
            private let barButtonItem: Input

            init(subscriber: S, barButtonItem: Input) {
                self.subscriber = subscriber
                self.barButtonItem = barButtonItem
                barButtonItem.target = self
                barButtonItem.action = #selector(eventHandler)
            }

            func request(_: Subscribers.Demand) {}

            func cancel() {
                subscriber = nil
            }

            @objc private func eventHandler() {
                _ = subscriber?.receive(barButtonItem)
            }
        }
    }
}

protocol UIBarButtonItemWithPublisher: UIBarButtonItem {}
extension UIBarButtonItem: UIBarButtonItemWithPublisher {}

extension UIBarButtonItemWithPublisher {
    var publisher: UIBarButtonItem.Publisher<Self> {
        .init(barButtonItem: self)
    }
}
