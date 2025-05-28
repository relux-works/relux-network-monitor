import Foundation
import Relux

extension NetworkMonitor.Business {
    public final class State: Relux.HybridState, ObservableObject {
        @Published public var networkStatus: Model.Status?
        @Published public var networkNotAvailable: Bool = false

        public init() {
            initPipeline()
        }
    }
}

extension NetworkMonitor.Business.State {
    private func initPipeline() {
        $networkStatus
            .map {
                switch $0?.connected {
                    case .none: false
                    case let .some(flag): flag.not
                }
            }
            .assign(to: &$networkNotAvailable)
    }
}

extension NetworkMonitor.Business.State {
    public func reduce(with action: Relux.Action) async {
        switch action as? NetworkMonitor.Business.Action {
            case let .some(action): await internalReduce(with: action)
            case .none: break
        }
    }

    public func cleanup() async {
        self.networkStatus = .none
    }
}
