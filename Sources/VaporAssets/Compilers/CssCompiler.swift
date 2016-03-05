//
//  CssCompiler.swift
//  Vapor Assets
//
//  Created by Shaun Harrison on 3/1/16.
//

import Foundation

public class CssCompiler: TaskCompiler {

	public override func compile(path: String, context: AnyObject? = nil) throws -> String? {
		if !self.shouldMinify {
			return String.fromContentsOfFile(path, encoding: NSUTF8StringEncoding)
		} else {
			return try super.compile(path, context: context)
		}
	}

	public override func getCompilationTask(path: String, context: AnyObject? = nil) -> Task {
		return Task(launchPath: "/usr/bin/env", arguments: [
			"cleancss",
			path
		])
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
