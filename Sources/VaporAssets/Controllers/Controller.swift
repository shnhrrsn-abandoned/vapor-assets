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

	required init() { }

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

		do {
			if let compiled = try asset.compile() {
				return Response(status: .OK, data: compiled.utf8, contentType: .Other(asset.mime))
			} else {
				throw CompilationError.UnknownError
			}
		} catch CompilationError.Error(let message) {
			return Response(status: .Error, text: message)
		} catch {
			return Response(status: .Error, text: "\(error)")
		}
	}

	private func info(request: Request) -> RequestInfo {
		let path = Application.workDir + "Resources" + request.path
		let fileExtension = NSURL(fileURLWithPath: path).pathExtension ?? ""
		return (path, fileExtension)
	}

}
