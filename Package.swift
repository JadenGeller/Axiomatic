
import PackageDescription

let package = Package(
    name: "Axiomatic",
    dependencies: [
        .Package(url: "https://github.com/JadenGeller/Gluey.git", majorVersion: 1)
    ]
)
