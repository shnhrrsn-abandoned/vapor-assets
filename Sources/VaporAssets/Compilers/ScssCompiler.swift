//
//  ScssCompiler.swift
//  Vapor Assets
//
//  Created by Shaun Harrison on 2/22/16.
//

import Foundation

public class ScssCompiler: TaskCompiler {
	public var includePaths = Array<String>()

	public override func getCompilationTask(path: String, context: AnyObject? = nil) -> Task {
		let minify = context as? String ?? (self.shouldMinify ? "compressed" : "nested")

		var arguments = [
			"node-sass",
			"--output-style", minify,
			"--precision=14"
		]

		for path in self.includePaths {
			arguments.append("--include-path")
			arguments.append(path)
		}

		arguments.append(path)

		return Task(launchPath: "/usr/bin/env", arguments: arguments)
	}

	public override func getLastModified(path: String, newest: Double = 0.0) -> Double {
		guard self.fileManager.fileExists(atPath: path) else {
			return newest
		}

		guard let date = (try? self.fileManager.attributesOfItem(atPath: path)[NSFileModificationDate]) as? NSDate else {
			return newest
		}

		var newest = max(newest, date.timeIntervalSinceReferenceDate)

		if let contents = String.fromContentsOfFile(path) {
			var startIndex = contents.startIndex
			let trimCharacterSet = NSCharacterSet.whitespaceAndNewline().mutableCopy() as! NSMutableCharacterSet
			trimCharacterSet.addCharacters(in: "'\"()")

			let directory = path.stringByDeletingLastPathComponent

			while let importRange = contents.range(of: "@import", range: startIndex..<contents.endIndex), endRange = contents.range(of: ";", range: importRange.endIndex..<contents.endIndex) {
				let importName = contents.substring(with: importRange.endIndex..<endRange.startIndex).trimmingCharacters(in: trimCharacterSet)
				let importPath = directory.stringByAppendingPathComponent(importName)
				let importExtension = importPath.pathExtension

				if importExtension != "scss" && importExtension != "sass" {
					let partialPath: String

					if importName.range(of: "/") != nil {
						partialPath = directory.stringByAppendingPathComponent(importName.stringByDeletingLastPathComponent).stringByAppendingPathComponent("_\(importName.lastPathComponent)")
					} else {
						partialPath = directory.stringByAppendingPathComponent("_\(importName.lastPathComponent)")
					}

					if self.fileManager.fileExists(atPath: "\(importPath).scss") {
						newest = self.getLastModified("\(importPath).scss", newest: newest)
					} else if self.fileManager.fileExists(atPath: "\(partialPath).scss") {
						newest = self.getLastModified("\(partialPath).scss", newest: newest)
					} else if self.fileManager.fileExists(atPath: "\(importPath).sass") {
						newest = self.getLastModified("\(importPath).sass", newest: newest)
					}
				} else {
					newest = self.getLastModified(importPath, newest: newest)
				}

				startIndex = endRange.endIndex
			}
		}

		return newest
	}

	public override var mime: String {
		return "text/css"
	}

	public override var type: String {
		return "css"
	}

	public override var fileExtension: String {
		return "css"
	}

}
