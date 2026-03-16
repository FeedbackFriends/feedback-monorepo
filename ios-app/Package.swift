// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Modules",
    platforms: [
        .macOS(.v14),
        .iOS("26")
    ],
    products: [
        .library(
            name: "RootFeature",
            targets: ["RootFeature"]),
        .library(
            name: "DesignSystem",
            targets: ["DesignSystem"]),
        .library(
            name: "EnterCodeFeature",
            targets: ["EnterCodeFeature"]),
        .library(
            name: "FeedbackFlowFeature",
            targets: ["FeedbackFlowFeature"]),
        .library(
            name: "MoreFeature",
            targets: ["MoreFeature"]),
        .library(
            name: "EventsFeature",
            targets: ["EventsFeature"]),
        .library(
            name: "TabbarFeature",
            targets: ["TabbarFeature"]),
        .library(
            name: "Logger",
            targets: ["Logger"]
        ),
        .library(
            name: "Localization",
            targets: ["Localization"]
        ),
        .library(
            name: "Model",
            targets: ["Model"]
        ),
        .library(
            name: "Utility",
            targets: ["Utility"]
        ),
        .library(
            name: "SignUpFeature",
            targets: ["SignUpFeature"]
        ),
        .library(
            name: "OpenAPI",
            targets: ["OpenAPI"]
        ),
        .library(
            name: "Implementations",
            targets: ["Implementations"]
        ),
        .library(
            name: "InfoPlist",
            targets: ["InfoPlist"]
        )
    ],
    dependencies: [
        .package(
            url: "git@github.com:pointfreeco/swift-snapshot-testing.git",
            exact: "1.18.3"
        ),
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            exact: "11.14.0"
        ),
        .package(
            url: "https://github.com/airbnb/lottie-ios",
            from: "3.4.3"
        ),
        .package(
            url: "https://github.com/google/GoogleSignIn-iOS.git",
            from: "7.0.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture.git",
            revision: "1.22.1"
        ),
        .package(
            url: "https://github.com/apple/swift-openapi-generator",
            .upToNextMinor(from: "1.10.2")
        ),
        .package(
            url: "https://github.com/apple/swift-openapi-runtime",
            .upToNextMinor(from: "1.8.2")
        ),
        .package(
            url: "https://github.com/apple/swift-openapi-urlsession",
            .upToNextMinor(from: "1.1.0")
        )
    ],
    targets: [
        .target(
            name: "Implementations",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebasePerformance", package: "firebase-ios-sdk"),
                "Logger",
                "Model",
                "Utility",
                "OpenAPI"
            ]
        ),
        .target(
            name: "OpenAPI",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
                "Model",
                "Utility"
            ],
            plugins: [.plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")]
        ),
        .target(
            name: "RootFeature",
            dependencies: [
                "DesignSystem",
                "TabbarFeature",
                "Model",
                "Utility",
                "EventsFeature",
                "Logger",
                "SignUpFeature"
            ]
        ),
        .target(
            name: "DesignSystem",
            dependencies: [
                "Model",
                "Utility",
                .product(name: "Lottie", package: "lottie-ios")
            ],
            resources: [
                .process("Resources/Fonts/Montserrat"),
                .process("Resources/Images/Images.xcassets"),
                .process("Resources/Lottie/Files")
            ]
        ),
        .target(
            name: "EnterCodeFeature",
            dependencies: [
                "DesignSystem",
                "FeedbackFlowFeature",
                "Model",
                "Utility",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "FeedbackFlowFeature",
            dependencies: [
                "DesignSystem",
                "Model",
                "Utility",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "MoreFeature",
            dependencies: [
                "DesignSystem",
                "Model",
                "Utility",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "EventsFeature",
            dependencies: [
                "DesignSystem",
                "Model",
                "Utility",
                "FeedbackFlowFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "TabbarFeature",
            dependencies: [
                "DesignSystem",
                "EnterCodeFeature",
                "EventsFeature",
                "MoreFeature",
                "Model",
                "Utility",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "Model",
            dependencies: [
                "Utility",
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "Utility",
            dependencies: [
                "Logger",
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "Logger"
        ),
        .target(
            name: "Localization"
        ),
        .target(
            name: "InfoPlist"
        ),
        .target(
            name: "SignUpFeature",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "DesignSystem",
                "Model",
                "Utility",
                "Logger"
            ]
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
                "RootFeature",
                "Implementations",
                "InfoPlist"
            ]
        )
    ]
)
