// swift-tools-version:5.0

import PackageDescription



let package = Package(
  name: "Cloudipsp",
  platforms: [.iOS(.v10)],
  products: [.library(name: "Cloudipsp", targets: ["Cloudipsp"])],
  targets: [.target(name: "Cloudipsp", path: "Cloudipsp", publicHeadersPath: "")]
)
