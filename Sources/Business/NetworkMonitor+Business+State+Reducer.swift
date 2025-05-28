import Foundation

extension NetworkMonitor.Business.State {
    func internalReduce(with action: NetworkMonitor.Business.Action) async {
        switch action {
            case let .networkStatusChanged(new):
                self.networkStatus = new
        }
    }
}
