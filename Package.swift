// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "usdToEur",
    products: [
        .executable(name: "usdToEur", targets: ["usdToEur"])
    ],
    targets: [
        .target(
            name: "usdToEur"
        )
    ]
)
