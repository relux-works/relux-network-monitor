import Combine
import Relux
import Testing
@testable import ReluxNetworkMonitor

@Suite("ReluxNetworkMonitor")
struct ReluxNetworkMonitorTests {
    @Test func statusDefaultsToUnknownValues() {
        let status = NetworkMonitor.Business.Model.Status()

        #expect(status.connected == nil)
        #expect(status.expensive == nil)
        #expect(status.wasChanged == nil)
        #expect(status.vpnEnabled == nil)
    }

    @Test func statusIsEquatable() {
        let left = NetworkMonitor.Business.Model.Status(
            connected: true,
            expensive: false,
            wasChanged: true,
            vpnEnabled: false
        )
        let right = NetworkMonitor.Business.Model.Status(
            connected: true,
            expensive: false,
            wasChanged: true,
            vpnEnabled: false
        )

        #expect(left == right)
    }

    @Test
    @MainActor
    func moduleRegistersStateAndSaga() async {
        let module = await NetworkMonitor.Module(dispatcher: Relux.Dispatcher(logger: Relux.Testing.Logger()))

        #expect(module.states.contains { $0 is NetworkMonitor.Business.State })
        #expect(module.sagas.contains { $0 is NetworkMonitor.Business.Saga })
    }

    @Test
    @MainActor
    func stateReducesNetworkStatusChanged() async {
        let state = NetworkMonitor.Business.State()
        let status = NetworkMonitor.Business.Model.Status(
            connected: false,
            expensive: true,
            wasChanged: true,
            vpnEnabled: false
        )

        await state.reduce(with: NetworkMonitor.Business.Action.networkStatusChanged(new: status))

        #expect(state.networkStatus == status)
        #expect(state.networkNotAvailable == true)
    }

    @Test
    @MainActor
    func stateCleanupResetsNetworkStatusAndDerivedAvailability() async {
        let state = NetworkMonitor.Business.State()
        let status = NetworkMonitor.Business.Model.Status(connected: false)

        await state.reduce(with: NetworkMonitor.Business.Action.networkStatusChanged(new: status))
        await state.cleanup()

        #expect(state.networkStatus == nil)
        #expect(state.networkNotAvailable == false)
    }

    @Test func sagaStartsAndStopsServiceObservation() async {
        let logger = Relux.Testing.Logger()
        let dispatcher = Relux.Dispatcher(logger: logger)
        let service = ServiceMock()
        let saga = await NetworkMonitor.Business.Saga(svc: service, dispatcher: dispatcher)

        await saga.apply(NetworkMonitor.Business.Effect.startObserveNetConditions)
        await saga.apply(NetworkMonitor.Business.Effect.stopObserveNetConditions)

        #expect(service.startCallCount == 1)
        #expect(service.stopCallCount == 1)
    }

    @Test func sagaForceCheckDispatchesCurrentStatus() async {
        let logger = Relux.Testing.Logger()
        let dispatcher = Relux.Dispatcher(logger: logger)
        let status = NetworkMonitor.Business.Model.Status(
            connected: true,
            expensive: false,
            wasChanged: true,
            vpnEnabled: true
        )
        let service = ServiceMock(status: status)
        let saga = await NetworkMonitor.Business.Saga(svc: service, dispatcher: dispatcher)

        await saga.apply(NetworkMonitor.Business.Effect.forceCheckNetConditions)

        #expect(logger.networkStatusActions().contains(status))
    }

    @Test func sagaDispatchesPublishedStatusChanges() async {
        let logger = Relux.Testing.Logger()
        let dispatcher = Relux.Dispatcher(logger: logger)
        let service = ServiceMock()
        let saga = await NetworkMonitor.Business.Saga(svc: service, dispatcher: dispatcher)
        let status = NetworkMonitor.Business.Model.Status(
            connected: false,
            expensive: false,
            wasChanged: true,
            vpnEnabled: false
        )

        service.publish(status)
        await waitFor {
            logger.networkStatusActions().contains(status)
        }

        #expect(logger.networkStatusActions().contains(status))
        await saga.apply(NetworkMonitor.Business.Effect.stopObserveNetConditions)
    }
}

private final class ServiceMock: NetworkMonitor.Business.IService, @unchecked Sendable {
    private let subject: CurrentValueSubject<NetworkMonitor.Business.Model.Status, Never>

    private(set) var startCallCount = 0
    private(set) var stopCallCount = 0

    var status: NetworkMonitor.Business.Model.Status {
        get async {
            subject.value
        }
    }

    var networkPub: AnyPublisher<NetworkMonitor.Business.Model.Status, Never> {
        subject.eraseToAnyPublisher()
    }

    init(status: NetworkMonitor.Business.Model.Status = .init()) {
        subject = CurrentValueSubject(status)
    }

    func start() async {
        startCallCount += 1
    }

    func stop() async {
        stopCallCount += 1
    }

    func publish(_ status: NetworkMonitor.Business.Model.Status) {
        subject.send(status)
    }
}

private extension Relux.Testing.Logger {
    func networkStatusActions() -> [NetworkMonitor.Business.Model.Status] {
        actions.compactMap { action in
            guard case let .networkStatusChanged(status) = action as? NetworkMonitor.Business.Action else {
                return nil
            }

            return status
        }
    }
}

private func waitFor(
    timeoutNanoseconds: UInt64 = 500_000_000,
    condition: @escaping @Sendable () -> Bool
) async {
    let deadline = ContinuousClock.now + .nanoseconds(Int(timeoutNanoseconds))

    while ContinuousClock.now < deadline {
        if condition() {
            return
        }

        try? await Task.sleep(nanoseconds: 10_000_000)
    }
}
