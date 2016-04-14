//
//  CompilationError.swift
//  Vapor Assets
//
//  Created by Shaun Harrison on 3/1/16.
//

public enum CompilationError: ErrorProtocol {
    case Error(message: String)
    case UnknownError
}
