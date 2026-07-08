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

<!-- relux-ecosystem:start -->

## About Relux Works

This project is part of the open-source ecosystem of
[Relux Works](https://relux.works), an AI-native software development studio.
We build fixed-price MVPs, rescue vibe-coded apps, run local AI inference, and
train teams to work with coding agents — and we open-source much of the
infrastructure behind it.

- Full catalog: [relux.works/en/open-source](https://relux.works/en/open-source/)
- Agentic enablement: [agent harnesses & team training](https://relux.works/en/agentic-enablement/)
- Hire us the agent-native way — point your assistant at `https://api.relux.works/mcp`
- Contact: ivan@relux.works

<!-- relux-ecosystem:end -->
