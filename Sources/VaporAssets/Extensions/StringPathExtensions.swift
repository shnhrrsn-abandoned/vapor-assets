//
//  StringPathExtensions.swift
//  Vapor Assets
//
//  Created by Shaun Harrison on 3/1/16.
//

import Foundation

extension String {

	internal var lastPathComponent: String {
		return (self as NSString).lastPathComponent
	}

	internal var pathComponents: [String] {
		return (self as NSString).pathComponents
	}

	internal var stringByDeletingPathExtension: String {
		return (self as NSString).stringByDeletingPathExtension
	}

	internal var stringByDeletingLastPathComponent: String {
		return (self as NSString).stringByDeletingLastPathComponent
	}

	internal func stringByAppendingPathComponent(str: String) -> String {
		return (self as NSString).stringByAppendingPathComponent(str)
	}

	internal var pathExtension: String {
		return (self as NSString).pathExtension
	}

}
