//
//  Compiler.swift
//  Vapor Assets
//
//  Created by Shaun Harrison on 2/22/16.
//

public class Compiler {
	public internal(set) var shouldMinify: Bool

	public required init(shouldMinify: Bool) {
		self.shouldMinify = shouldMinify
	}

	public func compile(path: String, context: AnyObject? = nil) throws -> String? {
		fatalError("Subclasses must implement \(#function)")
	}

	public func getLastModified(path: String, newest: Double = 0.0) -> Double {
		fatalError("Subclasses must implement \(#function)")
	}

	public var mime: String {
		fatalError("Subclasses must implement \(#function)")
	}

	public var type: String {
		fatalError("Subclasses must implement \(#function)")
	}

	public var fileExtension: String {
		fatalError("Subclasses must implement \(#function)")
	}

}
