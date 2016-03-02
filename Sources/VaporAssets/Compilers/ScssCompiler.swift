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
