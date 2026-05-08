# ReluxNetworkMonitor

Relux module for observing iOS network reachability and exposing the current
network status through Relux state.

## Installation

Add the package to the host app or package:

```swift
.package(url: "https://github.com/relux-works/relux-network-monitor.git", from: "1.0.1")
```

For local development in the Tap2Cash package set, use the sibling checkout:

```swift
.package(path: "../relux-network-monitor")
```

## Relux Registration

Register the module in the app Relux composition root:

```swift
await Relux(...)
    .register {
        await NetworkMonitor.Module()
    }
```

Start or stop network observation by dispatching effects:

```swift
await actions {
    NetworkMonitor.Business.Effect.startObserveNetConditions
}
```

Consume the state from SwiftUI as a Relux environment object:

```swift
@EnvironmentObject private var networkState: NetworkMonitor.UI.State
```

## Public State

`NetworkMonitor.Business.Model.Status` exposes:

- `connected`
- `expensive`
- `wasChanged`
- `vpnEnabled`

`NetworkMonitor.Business.State.networkNotAvailable` is derived from
`networkStatus.connected`.
