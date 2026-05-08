import Foundation
import Relux

extension NetworkMonitor {
    @MainActor
    public final class Module: Relux.Module {
        public let states: [any Relux.AnyState]
        public let sagas: [any Relux.Saga]

        public init(dispatcher: Relux.Dispatcher? = nil) async {
            self.sagas = [
                await NetworkMonitor.Business.Saga(
                    svc: NetworkMonitor.Business.Service(),
                    dispatcher: dispatcher
                )
            ]

            self.states = [
                NetworkMonitor.Business.State()
            ]
        }
    }
}
