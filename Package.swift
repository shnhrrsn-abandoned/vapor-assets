import PackageDescription

let package = Package(
	name: "VaporAssets",
	dependencies: [
		.Package(url: "https://github.com/qutheory/vapor.git", majorVersion: 0)
	]
)
