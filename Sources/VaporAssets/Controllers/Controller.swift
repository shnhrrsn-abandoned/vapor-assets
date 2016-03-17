//
//  AssetsController.swift
//  Vapor Assets
//
//  Created by Shaun Harrison on 2/22/16.
//

import Vapor
import Foundation
import CoreFoundation

private typealias RequestInfo = (path: String, fileExtension: String)

class Controller: Vapor.Controller {
	private let cache = NSCache()

	required init() { }

	func img(request: Request) -> ResponseConvertible {
		let info = self.info(request)

		let contentType: String

		switch info.fileExtension {
			case "svg":
				contentType = "image/svg+xml"
			case "eot":
				contentType = "application/vnd.ms-fontobject"
			case "woff":
				contentType = "application/x-font-woff"
			case "otf":
				contentType = "font/opentype"
			case "ttf":
				fallthrough
			default:
				contentType = "application/x-font-ttf"
		}

		return self.process(info, contentType: contentType)
	}

	func font(request: Request) -> ResponseConvertible {
		let info = self.info(request)

		let contentType: String

		switch info.fileExtension {
			case "svg":
				contentType = "image/svg+xml"
			case "png":
				contentType = "image/png"
			case "gif":
				contentType = "image/gif"
			case "ico":
				contentType = "image/x-icon"
				break
			case "jpeg", "jpg":
				fallthrough
			default:
				contentType = "image/jpeg"
		}

		return self.process(info, contentType: contentType)
	}

	func compile(request: Request) -> ResponseConvertible {
		let info = self.info(request)

		guard let asset = Asset(path: info.path) else {
			return Response(status: .Error, text: "Unsupported asset")
		}

		return self.process(info, contentType: asset.mime, asset: asset, lastModified: asset.getLastModified())
	}

	private func process(info: RequestInfo, contentType: String, asset: Asset? = nil, lastModified: Double? = nil) -> ResponseConvertible {
		let lastModified = lastModified ?? CFAbsoluteTimeGetCurrent()

		guard let asset = asset else {
			if let data = NSData(contentsOfFile: info.path) {
				return Response(status: .OK, data: data, contentType: .Other(contentType))
			} else {
				return Response(status: .NotFound, text: "Not found")
			}
		}

		let cacheKey = (info.path + String(lastModified)).bridgedObject
		let response: Response

		if let contents = self.cache.objectForKey(cacheKey) as? NSString {
			response = Response(status: .OK, data: String(contents).utf8, contentType: .Other(asset.mime))
		} else {
			do {
				if let compiled = try asset.compile() {
					self.cache.setObject(compiled.bridgedObject, forKey: cacheKey)
					response = Response(status: .OK, data: compiled.utf8, contentType: .Other(asset.mime))
				} else {
					throw CompilationError.UnknownError
				}
			} catch CompilationError.Error(let message) {
				return Response(status: .Error, text: message)
			} catch {
				return Response(status: .Error, text: "\(error)")
			}
		}

		// TODO: Support caching headers/etags

		return response
	}

	private func info(request: Request) -> RequestInfo {
		let path = Application.workDir + "Resources" + request.path
		let fileExtension = NSURL(fileURLWithPath: path).pathExtension ?? ""
		return (path, fileExtension)
	}

}
