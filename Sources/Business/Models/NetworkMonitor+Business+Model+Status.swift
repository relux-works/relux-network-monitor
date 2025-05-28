extension  NetworkMonitor.Business.Model {
    public struct Status {
        public let connected: Bool?
        public let expensive: Bool?
        public let wasChanged: Bool?
        public let vpnEnabled: Bool?

        public init(
            connected: Bool? = nil,
            expensive: Bool? = nil,
            wasChanged: Bool? = nil,
            vpnEnabled: Bool? = nil
        ) {
            self.connected = connected
            self.expensive = expensive
            self.wasChanged = wasChanged
            self.vpnEnabled = vpnEnabled
        }
    }
}

extension NetworkMonitor.Business.Model.Status: Equatable {}
extension NetworkMonitor.Business.Model.Status: Sendable {}
