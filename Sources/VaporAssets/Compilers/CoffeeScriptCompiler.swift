//
//  CoffeeScriptCompiler.swift
//  Vapor Assets
//
//  Created by Shaun Harrison on 3/1/16.
//

import Foundation

public class CoffeeScriptCompiler: TaskCompiler {

	public override func compile(path: String, context: AnyObject? = nil) throws -> String? {
		let coffee = Task(launchPath: "/usr/bin/env", arguments: [
			"coffee",
			"--compile",
			"--print",
			path
		])

		guard let value = try self.compileTask(coffee, path: path) else {
			return nil
		}

		if !self.shouldMinify {
			return value
		}

		let tempFile = NSTemporaryDirectory().stringByAppendingPathComponent("assets-\(NSUUID().UUIDString).js")
		try value.writeToFile(tempFile, atomically: false, encoding: NSUTF8StringEncoding)

		defer {
			let _ = try? NSFileManager.defaultManager().removeItemAtPath(tempFile)
		}

		let minify = Task(launchPath: "/usr/bin/env", arguments: [
			"uglifyjs",
			"--compress",
			"drop_console=true",
			tempFile
		])

		return try self.compileTask(minify, path: path)
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
