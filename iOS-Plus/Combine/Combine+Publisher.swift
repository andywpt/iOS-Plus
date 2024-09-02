import Combine
import Foundation

struct TimeoutError: Error {}
enum AsyncError: Error {
    case noValueReceived
}

extension Publisher {
    
    func delay(seconds: Double, on queue: DispatchQueue = .main) -> Publishers.Delay<Self, DispatchQueue> {
        delay(for: .seconds(seconds), tolerance: .zero, scheduler: queue)
    }
    // https://medium.com/geekculture/from-combine-to-async-await-c08bf1d15b77
    // https://www.apeth.com/UnderstandingCombine/subscribers/subscribersoneshot.html
    @discardableResult
    func firstValue() async -> Output? {
        await withCheckedContinuation { cont in
            var cancellable: AnyCancellable?
            var valueReceived = false
            cancellable = first()
                .sink { _ in
                    if !valueReceived { cont.resume(returning: nil) }
                    cancellable?.cancel()
                } receiveValue: { value in
                    valueReceived = true
                    cont.resume(returning: value)
                    cancellable?.cancel()
                }
        }
    }

    @discardableResult
    func firstValue(timeout: TimeInterval) async -> Output? {
        await withCheckedContinuation { cont in
            var cancellable: AnyCancellable?
            var valueReceived = false
            cancellable = first()
                .timeout(.seconds(timeout), scheduler: DispatchQueue.main)
                .sink { _ in
                    if !valueReceived { cont.resume(returning: nil) }
                    cancellable?.cancel()
                } receiveValue: { value in
                    valueReceived = true
                    cont.resume(returning: value)
                    cancellable?.cancel()
                }
        }
    }

    func withLatestFrom<Other: Publisher>(_ other: Other)
        -> AnyPublisher<(Self.Output, Other.Output), Failure>
        where Self.Failure == Other.Failure
    {
        map { value in (value: value, date: Date()) }
            .combineLatest(other)
            .removeDuplicates { $0.0.date == $1.0.date }
            .map { ($0.value, $1) }
            .eraseToAnyPublisher()
    }

    func mapToVoid() -> Publishers.Map<Self, Void> {
        map { _ in }
    }

    func withPriorValue() -> AnyPublisher<(prior: Output?, new: Output), Failure> {
        scan((prior: Output?.none, new: Output?.none)) { (prior: $0.new, new: $1) }
            .map { (prior: $0.0, new: $0.1!) }
            .eraseToAnyPublisher()
    }

    func bind<Output, Failure>(to subscriber: AnySubscriber<Output, Failure>) -> AnyCancellable where Output == Self.Output, Failure == Self.Failure {
        sink(receiveCompletion: { completion in
            subscriber.receive(completion: completion)
        }, receiveValue: { value in
            _ = subscriber.receive(value)
        })
    }

    func bind<S>(to subscriber: S) -> AnyCancellable where S: Subject, Self.Failure == S.Failure, Self.Output == S.Output {
        subscribe(subscriber)
    }

//    func assign<Root: AnyObject>(to keyPath: ReferenceWritableKeyPath<Root, Output>, on root: Root) -> AnyCancellable {
//          sink { [weak root] in
//               root?[keyPath: keyPath] = $0
//           }
//       }
}

extension Publisher where Failure == Never {
    // [weak] version of the assign(to:on:)
    func bind<Root: AnyObject>(to root: Root, _ keyPath: ReferenceWritableKeyPath<Root, Output>) -> AnyCancellable {
        sink { [weak root] in
            root?[keyPath: keyPath] = $0
        }
    }
}


extension Publisher {
    // The outcome is that values are dropped; some values emitted by the PassthroughSubject publisher at the head of the pipeline never arrive at the sink, because the .flatMap was “busy” at the time they were emitted:
    // Fix buffer(size: .max, prefetch: .byRequest, whenFull: .dropNewest)
    func `await`<T>(operation: @escaping @Sendable (Output) async -> T) -> AnyPublisher<Result<T, Never>, Failure> where T: Sendable, Output: Sendable {
        buffer(size: .max, prefetch: .byRequest, whenFull: .dropOldest)
            .flatMap(maxPublishers: .max(1)) { input in
                Deferred {
                    Future<Result<T, Never>, Failure> { promise in
                        Task {
                            let output = await operation(input)
                            promise(.success(.success(output)))
                        }
                    }
                }
            }
            .eraseToAnyPublisher()
    }

    func `await`<T>(operation: @escaping @Sendable (Output) async throws -> T) -> AnyPublisher<Result<T, Error>, Failure> where T: Sendable, Output: Sendable {
        buffer(size: .max, prefetch: .byRequest, whenFull: .dropOldest)
            .flatMap(maxPublishers: .max(1)) { value in
                Deferred {
                    Future<Result<T, Error>, Failure> { promise in
                        Task {
                            let result = await Result { try await operation(value) }
                            // Warning: Capture of 'promise' with non-sendable type '(Result<Result<T, any Error>, Self.Failure>) -> Void' in a `@Sendable` closure
                            // https://stackoverflow.com/a/78625862/21419169
                            promise(.success(result))
                        }
                    }
                }
            }
            .eraseToAnyPublisher()
    }
}

extension Result where Failure == any Error {
    init(catching body: () async throws -> Success) async {
        do {
            self = try await .success(body())
        } catch {
            self = .failure(error)
        }
    }
}

extension Publishers {
//    struct Await<Upstream, Output>: Publisher where Upstream: Publisher {
//
//        private let upstream: Upstream
//        private let transform: (Upstream.Output) async throws -> Output
//    }
}
