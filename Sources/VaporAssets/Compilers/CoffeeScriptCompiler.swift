//
//  CoffeeScriptCompiler.swift
//  Vapor Assets
//
//  Created by Shaun Harrison on 3/1/16.
//

import Foundation

public class CoffeeScriptCompiler: TaskCompiler {

	public override func compile(path: String, context: AnyObject? = nil) throws -> String? {
		let coffee = NSTask()
		coffee.launchPath = "/usr/bin/env"
		coffee.arguments = [
			"coffee",
			"-c",
			"-p",
			path
		]

		let value = try self.compileTask(coffee, path: path)

		guard let compiled = value where self.shouldMinify else {
			return value
		}

		let minify = NSTask()
		minify.launchPath = "/usr/bin/env"
		minify.arguments = [
			"uglifyjs",
			"--compress",
			"drop_console=true"
		]

		return try self.compileTask(minify, path: path, input: compiled)
	}

	public override var mime: String {
		return "application/javascript"
	}

	public override var type: String {
		return "js"
	}

	public override var fileExtension: String {
		return "js"
	}

}
