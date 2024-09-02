import Combine
import Foundation

extension Subject {
    func eraseToAnySubscriber() -> AnySubscriber<Output, Failure> {
        // AnySubscriber(self) will fail silently
        return AnySubscriber<Output, Failure>(
            receiveSubscription: { [weak self] subscription in
                guard let self else { return }
                send(subscription: subscription)
            },
            receiveValue: { [weak self] value -> Subscribers.Demand in
                guard let self else { return .none }
                send(value)
                return .unlimited
            },
            receiveCompletion: { [weak self] completion in
                self?.send(completion: completion)
            }
        )
    }
}
