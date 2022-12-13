// swift-tools-version:5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "KSPTelemetry",
    
    platforms: [.iOS(.v13), .macOS(.v10_15)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "KSPTelemetry",
            targets: ["KSPTelemetry"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
<<<<<<< HEAD
<<<<<<< HEAD
        .package(url: "https://github.com/mmuszynski/Keplerian.git", branch: "master")

=======
        .package(url: "https://github.com/mmuszynski/Keplerian.git", .upToNextMajor(from: "0.0.0"))
>>>>>>> more strict requirements for keplerian
=======
        .package(url: "https://github.com/mmuszynski/Keplerian.git", branch: "master")
>>>>>>> using master branch for development
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "KSPTelemetry",
            dependencies: [
                "Keplerian"
            ],
            exclude: ["Info.plist"]),
        .testTarget(
            name: "KSPTelemetryTests",
            dependencies: [
                "KSPTelemetry"
            ],
            exclude: ["Info.plist"])
    ]
)
