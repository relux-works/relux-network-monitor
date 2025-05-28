import Combine

extension Publisher where Output: Sendable, Failure == Never {
    public func sink(receiveValue: @Sendable @escaping (Output) async -> Void) -> AnyCancellable {
        sink { value in
            Task {
                await receiveValue(value)
            }
        }
    }
}
