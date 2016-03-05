//
//  Task.swift
//  Vapor Assets
//
//  Created by Shaun Harrison on 3/5/16.
//

// Workaround until NSTask is ready on Linux

public class Task {
	public var launchPath: String
	public var arguments: [String]?

	public var standardOutputHandler: ((String) -> Void)?
	public var standardErrorHandler: ((String) -> Void)?

	public private(set) var terminationStatus: Int = 0

	public init(launchPath: String, arguments: [String]? = nil) {
		self.launchPath = launchPath
		self.arguments = arguments
	}

	public func run() throws {
		var output = ""
		var error = ""

		var arguments = [ self.launchPath ]

		if let args = self.arguments {
			arguments += args
		}

		self.terminationStatus = try POSIX.popen(arguments, standardError: {
			error += $0
		}) {
			output += $0
		}

		if !output.isEmpty {
			self.standardOutputHandler?(output)
		}

		if !error.isEmpty {
			self.standardErrorHandler?(error)
		}
	}

}
