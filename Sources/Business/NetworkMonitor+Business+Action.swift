import Relux

extension NetworkMonitor.Business {
    public enum Action: Relux.Action {
        case networkStatusChanged(new: Model.Status)
    }
}
