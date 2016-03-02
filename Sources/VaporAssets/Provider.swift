//
//  AssetsProvider.swift
//  Vapor Assets
//
//  Created by Shaun Harrison on 2/22/16.
//

import Vapor
import VaporConsole

public class Provider: Vapor.Provider, ConsoleProvider {

	public static func boot(application: Application) {
		let controller = Controller()

		application.get("assets/:type/:a", handler: controller.compile)
		application.get("assets/:type/:a/:b", handler: controller.compile)
		application.get("assets/:type/:a/:b/:c", handler: controller.compile)
		application.get("assets/:type/:a/:b/:c/:d", handler: controller.compile)
		application.get("assets/:type/:a/:b/:c/:d/:e", handler: controller.compile)
	}

	public static func boot(console: Console) {

	}

}
