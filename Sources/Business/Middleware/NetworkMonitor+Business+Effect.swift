import Relux

extension NetworkMonitor.Business {
    public enum Effect: Relux.Effect {
        case startObserveNetConditions
        case stopObserveNetConditions
        case forceCheckNetConditions
    }
}
