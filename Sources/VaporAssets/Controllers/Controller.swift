//
//  AssetsController.swift
//  Vapor Assets
//
//  Created by Shaun Harrison on 2/22/16.
//

import Vapor
import Foundation

private typealias RequestInfo = (path: String, fileExtension: String)

class Controller: Vapor.Controller {

	func compile(request: Request) -> ResponseConvertible {
		let info = self.info(request)

		guard let asset = Asset(path: info.path) else {
			return "Error"
		}

		return self.process(info, contentType: asset.mime, asset: asset, lastModified: asset.getLastModified())
	}

	private func process(info: RequestInfo, contentType: String, asset: Asset? = nil, lastModified: Double? = nil) -> ResponseConvertible {
		let lastModified = lastModified ?? CFAbsoluteTimeGetCurrent()

		guard let asset = asset else {
			return try! String(contentsOfFile: info.path)
		}

		return asset.compile() ?? "Could not compile"
	}

	private func info(request: Request) -> RequestInfo {
		let path = Application.workDir + "Resources" + request.path
		let fileExtension = NSURL(fileURLWithPath: path).pathExtension ?? ""
		return (path, fileExtension)
	}

}
