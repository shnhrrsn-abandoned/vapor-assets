//
//  ScssCompiler.swift
//  Vapor Assets
//
//  Created by Shaun Harrison on 2/22/16.
//

import Foundation

public class ScssCompiler: TaskCompiler {
	var bin: String?

	public required init(shouldMinify: Bool) {
		super.init(shouldMinify: shouldMinify)

		self.bin = NSTask.execute("/usr/bin/which", arguments: [ "scss" ])?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

		if self.bin?.characters.count == 0 {
			self.bin = nil
		}
	}

	public override func getCompilationTask(path: String, context: AnyObject? = nil) -> NSTask {
		guard let bin = self.bin else {
			fatalError("\(self.dynamicType) is not supported.")
		}

		let minify = context as? String ?? (self.shouldMinify ? "compressed" : "nested")

		let task = NSTask()
		task.launchPath = bin
		task.arguments = [
			"-t", minify,
			"--compass",
			"--precision=14",
			path
		]

		return task
	}

	public override func getLastModified(path: String, newest: Double = 0.0) -> Double {
		return CFAbsoluteTimeGetCurrent()
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
