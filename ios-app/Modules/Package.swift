// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Modules",
    defaultLocalization: "da",
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
            name: "ActivityFeature",
            targets: ["ActivityFeature"]),
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
            name: "Domain",
            targets: ["Domain"]
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
            name: "Adapters",
            targets: ["Adapters"]
        ),
        .library(
            name: "InfoPlist",
            targets: ["InfoPlist"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift.git", exact: "2.39.0"),
        .package(url: "https://github.com/liamnichols/xcstrings-tool-plugin.git", exact: "1.2.0"),
        .package(url: "https://github.com/pointfreeco/xctest-dynamic-overlay", exact: "1.9.0"),
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git",
            exact: "12.9.0"
        ),
        .package(
            url: "https://github.com/airbnb/lottie-ios",
            from: "4.6.0"
        ),
        .package(
            url: "https://github.com/google/GoogleSignIn-iOS.git",
            from: "9.1.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-composable-architecture.git",
            exact: "1.26.0"
        ),
        .package(
            url: "https://github.com/apple/swift-openapi-generator",
            .upToNextMinor(from: "1.10.4")
        ),
        .package(
            url: "https://github.com/apple/swift-openapi-runtime",
            .upToNextMinor(from: "1.9.0")
        ),
        .package(
            url: "https://github.com/apple/swift-openapi-urlsession",
            .upToNextMinor(from: "1.2.0")
        ),
    ],
    targets: [
        .target(
            name: "Adapters",
            dependencies: [
                "Localization",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                .product(name: "Auth", package: "supabase-swift"),
                .product(name: "FirebaseMessaging", package: "firebase-ios-sdk"),
                .product(name: "FirebaseCrashlytics", package: "firebase-ios-sdk"),
                .product(name: "FirebasePerformance", package: "firebase-ios-sdk"),
                "Logger",
                "Domain",
                "Utility",
                "OpenAPI",
            ]
        ),
        .target(
            name: "OpenAPI",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession")
            ],
            path: "Sources/OpenAPI/GeneratedSources"
        ),
        .target(
            name: "OpenAPIGeneratorInput",
            dependencies: [],
            path: "Sources/OpenAPI",
            exclude: ["GeneratedSources"]
        ),
        .target(
            name: "RootFeature",
            dependencies: [
                "Localization",
                "DesignSystem",
                "TabbarFeature",
                "Domain",
                "Utility",
                "ActivityFeature",
                "Logger",
                "SignUpFeature"
            ]
        ),
        .target(
            name: "DesignSystem",
            dependencies: [
                "Localization",
                "Domain",
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
                "Localization",
                "DesignSystem",
                "FeedbackFlowFeature",
                "Domain",
                "Utility",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "FeedbackFlowFeature",
            dependencies: [
                "Localization",
                "DesignSystem",
                "Domain",
                "Utility",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "MoreFeature",
            dependencies: [
                "Localization",
                "DesignSystem",
                "Domain",
                "Utility",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "ActivityFeature",
            dependencies: [
                "Localization",
                "DesignSystem",
                "Domain",
                "Utility",
                "FeedbackFlowFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "TabbarFeature",
            dependencies: [
                "Localization",
                "DesignSystem",
                "EnterCodeFeature",
                "ActivityFeature",
                "MoreFeature",
                "Domain",
                "Utility",
                "SignUpFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "Domain",
            dependencies: [
                "Localization",
                "Utility",
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "Utility",
            dependencies: [
                "Localization",
                "Logger",
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .target(
            name: "Logger"
        ),
        .target(
            name: "Localization",
            exclude: ["AppBundleResources"],
            resources: [.process("Resources")],
            plugins: [.plugin(name: "XCStringsToolPlugin", package: "xcstrings-tool-plugin")]
        ),
        .target(
            name: "InfoPlist",
            dependencies: [
                "Logger",
                "Domain"
            ]
        ),
        .target(
            name: "SignUpFeature",
            dependencies: [
                "Localization",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "DesignSystem",
                "Domain",
                "Utility",
                "Logger"
            ]
        ),
        .testTarget(
            name: "InsightsTests",
            dependencies: [
                "ActivityFeature", "TabbarFeature", "RootFeature", "Adapters", "Domain", "OpenAPI",
                .product(name: "IssueReportingTestSupport", package: "xctest-dynamic-overlay")
            ],
            resources: [.copy("Fixtures")]
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                "Localization",
                .product(name: "IssueReportingTestSupport", package: "xctest-dynamic-overlay"),
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "RootFeature",
                "Adapters",
                "Domain",
                "OpenAPI",
                "InfoPlist"
            ]
        )
    ]
)
