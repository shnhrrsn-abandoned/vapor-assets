//
//  TaskCompiler.swift
//  Vapor Assets
//
//  Created by Shaun Harrison on 2/22/16.
//

import Foundation

public class TaskCompiler: Compiler {

	public override func compile(path: String, context: AnyObject? = nil) throws -> String? {
		return try self.compileTask(self.getCompilationTask(path, context: context), path: path)
	}

	public func getCompilationTask(path: String, context: AnyObject? = nil) -> NSTask {
		fatalError("Subclasses must implement \(#function)")
	}

	public func compileTask(task: NSTask, path: String, input: String? = nil) throws -> String? {
		let pipe = NSPipe()
		let errorPipe = NSPipe()

		task.standardOutput = pipe
		task.standardError = errorPipe

		if input != nil {
			task.standardInput = NSPipe()
		}

		task.launch()

		if let input = input?.dataUsingEncoding(NSUTF8StringEncoding), handle = (task.standardInput as? NSPipe)?.fileHandleForWriting {
			handle.writeData(input)
			handle.closeFile()
		}

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
