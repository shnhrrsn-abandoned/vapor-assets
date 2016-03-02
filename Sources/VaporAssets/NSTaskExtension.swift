//
//  NSTaskExtension.swift
//  Vapor Assets
//
//  Created by Shaun Harrison on 2/22/16.
//

import Foundation

extension NSTask {

	class func dataExecute(command: String, arguments: [String]? = nil) -> NSData? {
		let pipe = NSPipe()
		let task = NSTask()
		task.launchPath = command
		task.arguments = arguments
		task.standardOutput = pipe

		task.launch()

		return pipe.fileHandleForReading.readDataToEndOfFile()
	}

	class func execute(command: String, arguments: [String]? = nil) -> String? {
		guard let data = self.dataExecute(command, arguments: arguments) else {
			return nil
		}

		return String(data: data, encoding: NSUTF8StringEncoding)
	}

}
