import Foundation
import Network
@preconcurrency import Combine

extension NetworkMonitor.Business {
    public protocol IService: Sendable {
        typealias Status = NetworkMonitor.Business.Model.Status
        func start() async
        func stop() async
        var networkPub: AnyPublisher<Status, Never> { get }
        var status: Status { get async }
    }
}

extension NetworkMonitor.Business {
    public actor Service {
        private let monitor = NWPathMonitor()
        private let queue = DispatchQueue(label: "NetworkMonitor", qos: .userInitiated)
        public private(set) var status: Status = .init()
        nonisolated
        private let networkSub = CurrentValueSubject<Status, Never>(.init())

        public init() {
        }
    }
}

extension NetworkMonitor.Business.Service: NetworkMonitor.Business.IService {
    public func start() async {
        startWatchNetworkCondition()
    }

    public func stop() async {
        monitor.cancel()
    }

    nonisolated
    public var networkPub: AnyPublisher<Status, Never> {
        networkSub
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}

// network
extension  NetworkMonitor.Business.Service {
    nonisolated
    private func startWatchNetworkCondition() {
        let t1 = Date()
        monitor.pathUpdateHandler = { [weak self] path in
            Task {
                guard let self = self else {
                    return
                }

                let prevStatus = await self.status
                let nextStatus = await self.buildStatus(path: path, prevStatus: prevStatus)

                guard prevStatus != nextStatus else { return }
                await self.setStatus(nextStatus)
            }
        }

        monitor.start(queue: queue)
        let t2 = t1.distance(to: Date())
    }

    private func buildStatus(path: NWPath, prevStatus: Status) -> Status {
        let isExpensive = path.isExpensive
        let isConnected = path.status == .satisfied
        let wasChanged = prevStatus.connected != isConnected
        let isVpnEnabled = checkVPNEnabled()

        return .init(
            connected: isConnected,
            expensive: isExpensive,
            wasChanged: wasChanged,
            vpnEnabled: isVpnEnabled
        )
    }

    private func setStatus(_ status: Status) {
        self.status = status
        networkSub.send(status)
    }
}

// vpn helper
extension  NetworkMonitor.Business.Service {
    private static let vpnProtocols = ["tap", "tun", "ppp", "ipsec", "utun"]

    private func checkVPNEnabled() -> Bool {
        guard let cfDict = CFNetworkCopySystemProxySettings() else { return false }

        let nsDict = cfDict.takeRetainedValue() as NSDictionary
        guard let keys = nsDict["__SCOPED__"] as? NSDictionary,
              let allKeys = keys.allKeys as? [String]
              else { return false }

        return allKeys
            .contains { key in
                Self.vpnProtocols.contains { ptcl in key.contains(ptcl)}
            }
    }
}
