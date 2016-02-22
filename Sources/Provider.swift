//
//  AssetsProvider.swift
//  Vapor Assets
//
//  Created by Shaun Harrison on 2/22/16.
//

import Vapor

public class Provider: Vapor.Provider {

	public static func boot(application: Application) {
		let controller = Controller()

		application.get("assets/:type/:a", closure: controller.compile)
		application.get("assets/:type/:a/:b", closure: controller.compile)
		application.get("assets/:type/:a/:b/:c", closure: controller.compile)
		application.get("assets/:type/:a/:b/:c/:d", closure: controller.compile)
		application.get("assets/:type/:a/:b/:c/:d/:e", closure: controller.compile)

	}

}
