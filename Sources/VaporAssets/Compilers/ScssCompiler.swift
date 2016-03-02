//
//  ScssCompiler.swift
//  Vapor Assets
//
//  Created by Shaun Harrison on 2/22/16.
//

import Foundation

public class ScssCompiler: TaskCompiler {

	public override func getCompilationTask(path: String, context: AnyObject? = nil) -> NSTask {
		let minify = context as? String ?? (self.shouldMinify ? "compressed" : "nested")

		let task = NSTask()
		task.launchPath = "/usr/bin/env"
		task.arguments = [
			"node-sass",
			"--output-style", minify,
			"--precision=14",
			path
		]

		return task
	}

	public override func getLastModified(path: String, newest: Double = 0.0) -> Double {
		guard self.fileManager.fileExistsAtPath(path) else {
			return newest
		}

		guard let date = (try? self.fileManager.attributesOfItemAtPath(path)[NSFileModificationDate]) as? NSDate else {
			return newest
		}

		var newest = max(newest, date.timeIntervalSinceReferenceDate)

		if let contents = try? String(contentsOfFile: path) {
			var startIndex = contents.startIndex
			let trimCharacterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet().mutableCopy() as! NSMutableCharacterSet
			trimCharacterSet.addCharactersInString("'\"()")

			let directory = path.stringByDeletingLastPathComponent

			while let importRange = contents.rangeOfString("@import", range: Range(start: startIndex, end: contents.endIndex)), endRange = contents.rangeOfString(";", range: Range(start: importRange.endIndex, end: contents.endIndex)) {
				let importName = contents.substringWithRange(Range(start: importRange.endIndex, end: endRange.startIndex)).stringByTrimmingCharactersInSet(trimCharacterSet)
				let importPath = directory.stringByAppendingPathComponent(importName)
				let importExtension = importPath.pathExtension

				if importExtension != "scss" && importExtension != "sass" {
					let partialPath: String

					if importName.rangeOfString("/") != nil {
						partialPath = directory.stringByAppendingPathComponent(importName.stringByDeletingLastPathComponent).stringByAppendingPathComponent("_\(importName.lastPathComponent)")
					} else {
						partialPath = directory.stringByAppendingPathComponent("_\(importName.lastPathComponent)")
					}

					if self.fileManager.fileExistsAtPath("\(importPath).scss") {
						newest = self.getLastModified("\(importPath).scss", newest: newest)
					} else if self.fileManager.fileExistsAtPath("\(partialPath).scss") {
						newest = self.getLastModified("\(partialPath).scss", newest: newest)
					} else if self.fileManager.fileExistsAtPath("\(importPath).sass") {
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
