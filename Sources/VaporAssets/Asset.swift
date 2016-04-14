//
//  Asset.swift
//  Vapor Assets
//
//  Created by Shaun Harrison on 2/22/16.
//

import Foundation

public class Asset {
	public static var shouldMinifyDefault = false {
		didSet {
			for (_, compiler) in self.compilers {
				compiler.shouldMinify = self.shouldMinifyDefault
			}
		}
	}

	public static var compilers: [String: Compiler] = [
		"scss": ScssCompiler(shouldMinify: false),
		"coffee": CoffeeScriptCompiler(shouldMinify: false),
		"js": JavascriptCompiler(shouldMinify: false),
		"css": CssCompiler(shouldMinify: false),
	]

	public let shouldMinify: Bool
	public let path: String
	public let compiler: Compiler

	public init?(path: String, shouldMinify: Bool? = nil) {
		self.path = path
		self.shouldMinify = shouldMinify ?? Asset.shouldMinifyDefault

		if let compiler = Asset.getCompilerFromPath(path) {
			self.compiler = compiler
		} else {
			return nil
		}
	}

	public func compile(context: AnyObject? = nil) throws -> String? {
		return try self.compiler.compile(self.path, context: context)
	}

	public func getLastModified(newest: Double = 0.0) -> Double {
		return self.compiler.getLastModified(self.path, newest: newest)
	}

	public var mime: String {
		return self.compiler.mime
	}

	public var type: String {
		return self.compiler.type
	}

	public var fileExtension: String {
		return self.compiler.fileExtension
	}

	public class func getCompilerFromPath(path: String) -> Compiler? {
		let pathExtension = path.pathExtension.lowercased()

		for (key, compiler) in self.compilers {
			if pathExtension == key {
				return compiler
			}
		}

		return nil
	}

	public class func isPathSupported(path: String) -> Bool {
		let pathExtension = path.pathExtension.lowercased()

		for (key, _) in self.compilers {
			if pathExtension == key {
				return true
			}
		}

		return false
	}

}
