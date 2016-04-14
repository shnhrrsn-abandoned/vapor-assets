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

class Controller: ApplicationInitializable {
	private let app: Application
	private let cache = NSCache()

	required init(application: Application) {
		self.app = application
	}

	func img(request: Request) -> ResponseRepresentable {
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

	func font(request: Request) -> ResponseRepresentable {
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

	func compile(request: Request) -> ResponseRepresentable {
		let info = self.info(request)

		guard let asset = Asset(path: info.path) else {
			return Response(status: .badRequest, text: "Unsupported asset")
		}

		return self.process(info, contentType: asset.mime, asset: asset, lastModified: asset.getLastModified())
	}

	private func process(info: RequestInfo, contentType: String, asset: Asset? = nil, lastModified: Double? = nil) -> ResponseRepresentable {
		let lastModified = lastModified ?? CFAbsoluteTimeGetCurrent()

		guard let asset = asset else {
			if let data = NSData(contentsOfFile: info.path) {
				let bytes = UnsafeBufferPointer<UInt8>(start: UnsafePointer<UInt8>(data.bytes), count: data.length)
				var response = Response(status: .ok, data: Data(bytes))
				response.headers["Content-Type"] = Response.Headers.Value(contentType)
				return response
			} else {
				return Response(status: .notFound, text: "Not found")
			}
		}

		let cacheKey = (info.path + String(lastModified)).bridgedObject
		var response: Response

		if let contents = self.cache.object(forKey: cacheKey) as? NSString {
			response = Response(status: .ok, data: Data(String(contents).utf8))
			response.headers["Content-Type"] = Response.Headers.Value(asset.mime)
		} else {
			do {
				if let compiled = try asset.compile() {
					self.cache.setObject(compiled.bridgedObject, forKey: cacheKey)
					response = Response(status: .ok, data: Data(compiled.utf8))
					response.headers["Content-Type"] = Response.Headers.Value(asset.mime)
				} else {
					throw CompilationError.UnknownError
				}
			} catch CompilationError.Error(let message) {
				return Response(status: .badRequest, text: message)
			} catch {
				return Response(status: .badRequest, text: "\(error)")
			}
		}

		// TODO: Support caching headers/etags

		return response
	}

	private func info(request: Request) -> RequestInfo {
		let path = self.app.workDir + "Resources" + request.uri.path!
		let fileExtension = NSURL(fileURLWithPath: path).pathExtension ?? ""
		return (path, fileExtension)
	}

}
