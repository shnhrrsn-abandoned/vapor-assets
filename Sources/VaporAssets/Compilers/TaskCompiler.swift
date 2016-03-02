//
//  TaskCompiler.swift
//  Vapor Assets
//
//  Created by Shaun Harrison on 2/22/16.
//

import Foundation

public class TaskCompiler: Compiler {

	public override func compile(path: String, context: AnyObject? = nil) throws -> String? {
		return try self.compileTask(self.getCompilationTask(path, context: context), path: path);
	}

	public func getCompilationTask(path: String, context: AnyObject? = nil) -> NSTask {
		fatalError("Subclasses must implement \(#function)")
	}

	public func compileTask(task: NSTask, path: String) throws -> String? {
		let pipe = NSPipe()
		let errorPipe = NSPipe()
		task.standardOutput = pipe
		task.standardError = errorPipe

		task.launch()

		let data = pipe.fileHandleForReading.readDataToEndOfFile()
		let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()

		if task.terminationStatus != 0 {
			if let message = String(data: errorData, encoding: NSUTF8StringEncoding) {
				throw CompilationError.Error(message: message)
			} else {
				throw CompilationError.UnknownError
			}
		}

		return String(data: data, encoding: NSUTF8StringEncoding)
	}

}
