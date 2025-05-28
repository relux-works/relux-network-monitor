# iOS Feature Management

## Adding Dependency to the Project

- Add the dependency to the project
- Connect to Relux:

  ```swift
  Relux.register(FeatureManagement.module())
  ```

- Configure in the project

## Feature Configuration

### Define Features

```swift
extension FeatureManagement.Business.Model {
    enum MyAppFeature: FeatureManagement.Business.Model.Feature.Key {
        case debugMenu = "debugMenu"
        case feature1 = "feature1"
    }
}
```

### Add Protocols

```swift
extension FeatureManagement.Business.Model.MyAppFeature: CaseIterable {}
extension FeatureManagement.Business.Model.MyAppFeature: RawRepresentable {}

extension FeatureManagement.Business.Model.MyAppFeature: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self.init(rawValue: value)!
    }
}

extension FeatureManagement.Business.Model.MyAppFeature: Codable {}

extension FeatureManagement.Business.Model.MyAppFeature: Identifiable {
    var id: FeatureManagement.Business.Model.Feature.Key { rawValue }
}
```

## Extend `FeatureManagement.ViewState`

```swift
extension FeatureManagement.UI.State {
    var allMembraneFeatures: [FeatureManagement.Business.Model.MyAppFeature] {
        self.allFeatures
            .compactMap { FeatureManagement.Business.Model.MyAppFeature(rawValue: $0.key) }
    }

    func check(expression: FeatureManagement.Business.Model.FeatureComposite) -> Bool {
        expression.check(against: enabledFeatures)
    }
}
```

### Convert Sequences

```swift
extension Sequence where Element == FeatureManagement.Business.Model.Feature.Key {
    var asMyAppFeatures: [FeatureManagement.Business.Model.MyAppFeature] {
        self.compactMap { .init(rawValue: $0) }
    }
}
```

## Define Exact Feature Expressions

```swift
extension FeatureManagement.Business.Model.FeatureComposite {
    static func exactFeature(_ feature: FeatureManagement.Business.Model.MyAppFeature) -> Self {
        .feature(feature.rawValue)
    }
}
```

## Propagate Features to the Root View

### Connect `envObject` to View

```swift
@EnvironmentObject private var featuresState: FeatureManagement.UI.State
```

### Add Feature Propagating Modifier to View

```swift
.bindEnabledFeatures(featureState: featuresState)
```

## Using Features in the UI

```swift
Group {
    divider
    Relux.NavigationLink(page: .membraneApp(page: .account(page: .debugMenu))) {
        CustomMenuItem(model: SettingPage.debug.model)
    }
}
.presentIf(
    .anySatisfy(composites: [
        .exactFeature(.debugMenu),
        .condition({ DeviceEnv.isSimulator })
    ])
)
```

