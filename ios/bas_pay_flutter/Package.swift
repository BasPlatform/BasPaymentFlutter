// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "bas_pay_flutter",
    platforms: [
        .iOS("13.0"),
    ],
    products: [
        .library(name: "bas-pay-flutter", targets: ["bas_pay_flutter"]),
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
    ],
    targets: [
        // Update url + checksum when publishing a new XCFramework release.
        .binaryTarget(
            name: "bas_pay",
            url: "https://github.com/BasPlatform/BasPayment-IOS/releases/download/1.0.3/bas_pay.xcframework.zip",
            checksum: "9110dc9062111f7dd98c8893bfedffe5bb85594f20231a775c68efe225a0d46f"
        ),
        .target(
            name: "bas_pay_flutter",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                "bas_pay",
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ],
            linkerSettings: [
                .linkedFramework("bas_pay"),
            ]
        ),
    ]
)
