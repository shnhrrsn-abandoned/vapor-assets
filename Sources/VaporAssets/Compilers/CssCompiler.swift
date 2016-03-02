//
//  CssCompiler.swift
//  Vapor Assets
//
//  Created by Shaun Harrison on 3/1/16.
//

import Foundation

public class CssCompiler: TaskCompiler {

	public override func compile(path: String, context: AnyObject? = nil) throws -> String? {
		let contents = try String(contentsOfFile: path, encoding: NSUTF8StringEncoding)

		guard self.shouldMinify else {
			return contents
		}

		let minify = NSTask()
		minify.launchPath = "/usr/bin/env"
		minify.arguments = [
			"cleancss"
		]

		return try self.compileTask(minify, path: path, input: contents)
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
