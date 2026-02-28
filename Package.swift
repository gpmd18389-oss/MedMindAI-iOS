// swift-tools-version: 5.9
// MedMindAI iOS App
// 注意：此文件用于 Swift Package Manager 构建。
// 正式开发请在 Xcode 中创建 iOS App 项目，然后将 MedMindAI/ 目录中的文件添加到项目。

import PackageDescription

let package = Package(
    name: "MedMindAI",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "MedMindAI",
            targets: ["MedMindAI"]
        )
    ],
    targets: [
        .target(
            name: "MedMindAI",
            path: "MedMindAI"
        )
    ]
)
