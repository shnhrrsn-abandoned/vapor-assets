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

	public func getCompilationTask(path: String, context: AnyObject? = nil) -> Task {
		fatalError("Subclasses must implement \(#function)")
	}

	public func compileTask(task: Task, path: String) throws -> String? {
		var output: String?
		var error: String?

		task.standardOutputHandler = {
			output = $0
		}

		task.standardErrorHandler = {
			error = $0
		}

		try task.run()

		if task.terminationStatus != 0 {
			if let message = error {
				throw CompilationError.Error(message: message)
			} else {
				throw CompilationError.UnknownError
			}
		}

		return output
	}

}
