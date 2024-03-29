import ProjectDescription
import ProjectDescriptionHelpers

let dependencies = Dependencies(
    carthage: [],
    swiftPackageManager: .init(
        [
            .remote(url: "https://github.com/Alamofire/Alamofire.git",
                requirement: .upToNextMajor(from: "5.8.1")),
            .remote(url: "https://github.com/Alamofire/AlamofireImage.git",
                    requirement: .upToNextMajor(from: "4.3.0")),
            .remote(url: "https://github.com/CSolanaM/SkeletonUI.git", requirement: .branch("master")),
            .remote(url: "https://github.com/apple/swift-crypto.git", requirement: .upToNextMajor(from: "3.0.0")),
            .remote(url: "https://github.com/firebase/firebase-ios-sdk", requirement: .branch("main"))
        ]
    ),
    platforms: [.iOS]
)
