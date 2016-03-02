//
//  InstallToolchainCommand.swift
//  Vapor Assets
//
//  Created by Shaun Harrison on 3/1/16.
//

import VaporConsole

#if os(Linux)
	import Glibc
#else
	import Darwin
#endif

public class InstallToolchainCommand: Command {

	public override var name: String {
		return "assets:install-toolchain"
	}

	public override var help: String? {
		return "Installs necessary tools for compiling assets."
	}

	public override func handle() {
		guard self.hasBin("npm") else {
			self.error("ERROR: NPM not installed")
			self.info(" --> NPM needs to be installed before running \(self.name)")
			self.info(" --> Install NPM by running the following:")

			#if os(Linux)
				self.info("        `apt-get install npm -y`")
			#else
				self.info("        `sudo curl -L https://npmjs.org/install.sh | sh`")
			#endif

			return
		}

		if !self.hasBin("node-sass") && !self.installNpmPackage("node-sass") {
			return
		}

		if !self.hasBin("coffee") && !self.installNpmPackage("coffee-script") {
			return
		}

		if !self.hasBin("uglifyjs") && !self.installNpmPackage("uglify-js") {
			return
		}

		if !self.hasBin("cleancss") && !self.installNpmPackage("clean-css") {
			return
		}

		self.comment("Toolchain is installed!")
	}

	private func hasBin(bin: String) -> Bool {
		return system("/usr/bin/env which \(bin) > /dev/null") == 0
	}

	private func installNpmPackage(package: String) -> Bool {
		self.info("Installing \(package)")

		if system("/usr/bin/env npm install \(package) -g") == 0 {
			return true
		} else {
			self.error(" --> Error installing \(package)")
			return false
		}
	}

}
