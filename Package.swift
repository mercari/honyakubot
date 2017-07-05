// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "honyakubot",
    dependencies: [
        .Package(url: "https://github.com/SlackKit/SlackKit.git", majorVersion: 4),
        .Package(url: "https://github.com/Alamofire/Alamofire.git", majorVersion: 4),
        .Package(url: "https://github.com/ReactiveCocoa/ReactiveSwift.git", "2.0.0-rc.1"),
    ]
)
