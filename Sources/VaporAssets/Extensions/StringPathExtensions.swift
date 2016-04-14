//
//  StringPathExtensions.swift
//  Vapor Assets
//
//  Created by Shaun Harrison on 3/1/16.
//

import Foundation

extension String {

	// Fix for Linux pending https://github.com/apple/swift-corelibs-foundation/blob/master/Foundation/NSString.swift#L1285
	static func fromContentsOfFile(path: String, encoding: NSStringEncoding = NSUTF8StringEncoding) -> String? {
		guard let data = NSData(contentsOfFile: path) else {
			return nil
		}

		return self.init(data: data, encoding: encoding)
	}

	internal var lastPathComponent: String {
		return self.bridgedObject.lastPathComponent
	}

	internal var pathComponents: [String] {
		return self.bridgedObject.pathComponents
	}

	internal var stringByDeletingPathExtension: String {
		return self.bridgedObject.deletingPathExtension
	}

	internal var stringByDeletingLastPathComponent: String {
		return self.bridgedObject.deletingLastPathComponent
	}

	internal func stringByAppendingPathComponent(str: String) -> String {
		return self.bridgedObject.appendingPathComponent(str)
	}

	internal var pathExtension: String {
		return self.bridgedObject.pathExtension
	}

	internal var bridgedObject: NSString {
		#if os(Linux)
			return self._bridgeToObject()
		#else
			return self as NSString
		#endif
	}

}
