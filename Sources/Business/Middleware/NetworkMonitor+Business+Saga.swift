import Combine
import Relux

extension NetworkMonitor.Business {
    public protocol ISaga: Relux.Saga {
        typealias NetworkStatus = Model.Status
    }
}

extension NetworkMonitor.Business {
    public actor Saga {
        private let svc: IService
        private var pipelines: Set<AnyCancellable> = []

        public init(svc: IService) async {
            self.svc = svc
            await setupSubscriptions()
        }
    }
}

extension NetworkMonitor.Business.Saga: NetworkMonitor.Business.ISaga {
    public func apply(_ effect: any Relux.Effect) async {
        switch effect as? NetworkMonitor.Business.Effect {
            case .none: break
            case .startObserveNetConditions: await startObserveNetConditions()
            case .stopObserveNetConditions: await stopObserveNetConditions()
            case .forceCheckNetConditions: await forceCheckNetConditions()
        }
    }
}

extension NetworkMonitor.Business.Saga {
    private func startObserveNetConditions() async {
        await svc.start()
    }

    private func stopObserveNetConditions() async {
        await svc.stop()
    }

    private func forceCheckNetConditions() async {
        let status = await self.svc.status
        await action {
            NetworkMonitor.Business.Action.networkStatusChanged(new: status)
        }
    }
}

// subscriptions
extension NetworkMonitor.Business.Saga {
    private func setupSubscriptions() async {
        svc.networkPub
            .sink { [weak self] status in
                await self?.onNetworkStatusChange(status)
            }
            .store(in: &pipelines)
    }

    private func onNetworkStatusChange(_ status: NetworkStatus) async {
        await actions {
            NetworkMonitor.Business.Action.networkStatusChanged(new: status)
        }
    }
}
