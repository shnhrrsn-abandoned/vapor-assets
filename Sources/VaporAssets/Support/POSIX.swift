// Imported from swift-package-manager:
// https://github.com/apple/swift-package-manager/blob/master/Sources/POSIX

#if os(Linux)
	import Glibc
#else
	import Darwin.C
#endif

/*
 This source file is part of the Swift.org open source project

 Copyright 2015 - 2016 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See http://swift.org/LICENSE.txt for license information
 See http://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

internal class POSIX {

	internal enum SystemError: ErrorType {
		case close(Int32)
		case pipe(Int32)
		case popen(Int32, String)
		case posix_spawn(Int32, [String])
		case read(Int32)
		case waitpid(Int32)
	}

	internal enum Error: ErrorType {
		case ExitSignal
	}

	internal enum ShellError: ErrorType {
		case system(arguments: [String], SystemError)
		case popen(arguments: [String], SystemError)
	}

	internal class func env(key: String) -> String? {
		let out = getenv(key)
		return out == nil ? nil : String.fromCString(out)  //FIXME locale may not be UTF8
	}

	private class func spawnp(path: String, args: [String], environment: [String: String] = [:], fileActions: posix_spawn_file_actions_t? = nil) throws -> pid_t {
		var environment = environment
		let argv = args.map{ $0.withCString(strdup) }
		defer { for arg in argv { free(arg) } }

		for key in ["PATH", "HOME" ] {
			environment[key] = self.env(key)
		}

		let env = environment.map{ "\($0.0)=\($0.1)".withCString(strdup) }
		defer { env.forEach{ free($0) } }

		var pid = pid_t()
		let rv: Int32
		if var fileActions = fileActions {
			rv = posix_spawnp(&pid, argv[0], &fileActions, nil, argv + [nil], env + [nil])
		} else {
			rv = posix_spawnp(&pid, argv[0], nil, nil, argv + [nil], env + [nil])
		}
		guard rv == 0 else {
			throw SystemError.posix_spawn(rv, args)
		}

		return pid
	}


	private class func _WSTATUS(status: CInt) -> CInt {
		return status & 0x7f
	}

	private class func WIFEXITED(status: CInt) -> Bool {
		return _WSTATUS(status) == 0
	}

	private class func WEXITSTATUS(status: CInt) -> CInt {
		return (status >> 8) & 0xff
	}

	private class func wait(pid: pid_t) throws -> Int32 {
		while true {
			var exitStatus: Int32 = 0
			let rv = waitpid(pid, &exitStatus, 0)

			if rv != -1 {
				if WIFEXITED(exitStatus) {
					return WEXITSTATUS(exitStatus)
				} else {
					throw Error.ExitSignal
				}
			} else if errno == EINTR {
				continue  // see: man waitpid
			} else {
				throw SystemError.waitpid(errno)
			}
		}
	}

	internal class func popen(arguments: [String], environment: [String: String] = [:], standardError: (String -> Void)? = nil, standardOutput: String -> Void) throws -> Int {
		do {
			// Create a pipe to use for reading the result.
			var pipe: [Int32] = [0, 0]
			var errorPipe: [Int32] = [0, 0]

			#if os(Linux)
				var rv = Glibc.pipe(&pipe)
				Glibc.pipe(&errorPipe)
			#else
				var rv = Darwin.pipe(&pipe)
				Darwin.pipe(&errorPipe)
			#endif

			guard rv == 0 else {
				throw SystemError.pipe(rv)
			}

			// Create the file actions to use for spawning.
			var fileActions = posix_spawn_file_actions_t()
			posix_spawn_file_actions_init(&fileActions)

			// Open /dev/null as stdin.
			posix_spawn_file_actions_addopen(&fileActions, 0, "/dev/null", O_RDONLY, 0)

			// Open the write end of the pipe as stdout.
			posix_spawn_file_actions_adddup2(&fileActions, pipe[1], 1)

			// Open the write end of the error pipe as stderr.
			posix_spawn_file_actions_adddup2(&fileActions, errorPipe[1], 2)

			// Close the other ends of the pipe.
			posix_spawn_file_actions_addclose(&fileActions, pipe[0])
			posix_spawn_file_actions_addclose(&fileActions, pipe[1])
			posix_spawn_file_actions_addclose(&fileActions, errorPipe[0])
			posix_spawn_file_actions_addclose(&fileActions, errorPipe[1])

			// Launch the command.
			let pid = try spawnp(arguments[0], args: arguments, environment: environment, fileActions: fileActions)

			// Clean up the file actions.
			posix_spawn_file_actions_destroy(&fileActions)

			// Close the write end of the output pipe.
			rv = close(pipe[1])
			guard rv == 0 else {
				throw SystemError.close(rv)
			}

			// Close the write end of the error pipe.
			close(errorPipe[1])

			// Read all of the data from the output pipe.
			let N = 4096
			var buf = [Int8](count: N + 1, repeatedValue: 0)

			loop: while true {
				let n = read(pipe[0], &buf, N)
				switch n {
				case  -1:
					if errno == EINTR {
						continue  // try again!
					} else {
						throw SystemError.read(errno)
					}
				case 0:
					break loop
				default:
					buf[n] = 0 // must null terminate
					if let str = String.fromCString(buf) {
						standardOutput(str)
					} else {
						throw SystemError.popen(EILSEQ, arguments[0])
					}
				}
			}

			if let standardError = standardError {
				loop: while true {
					let n = read(errorPipe[0], &buf, N)
					switch n {
					case  -1:
						if errno == EINTR {
							continue  // try again!
						}
					case 0:
						break loop
					default:
						buf[n] = 0 // must null terminate
						if let str = String.fromCString(buf) {
							standardError(str)
						}
					}
				}
			}

			// Close the read end of the output pipe.
			close(pipe[0])

			// Close the read end of the error pipe.
			close(errorPipe[0])

			// Wait for the command to exit.
			return Int(try wait(pid))
		} catch let underlyingError as SystemError {
			throw ShellError.popen(arguments: arguments, underlyingError)
		}
	}

}
