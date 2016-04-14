//
//  Compiler.swift
//  Vapor Assets
//
//  Created by Shaun Harrison on 2/22/16.
//

import Foundation

public class Compiler {
	public internal(set) var shouldMinify: Bool

	internal let fileManager = NSFileManager.defaultManager()

	public required init(shouldMinify: Bool) {
		self.shouldMinify = shouldMinify
	}

	public func compile(path: String, context: AnyObject? = nil) throws -> String? {
		fatalError("Subclasses must implement \(#function)")
	}

	public func getLastModified(path: String, newest: Double = 0.0) -> Double {
		guard self.fileManager.fileExists(atPath: path) else {
			return newest
		}

		guard let date = (try? self.fileManager.attributesOfItem(atPath: path)[NSFileModificationDate]) as? NSDate else {
			return newest
		}

		return max(newest, date.timeIntervalSinceReferenceDate)
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
