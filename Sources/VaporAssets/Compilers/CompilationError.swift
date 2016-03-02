//
//  CompilationError.swift
//  Vapor Assets
//
//  Created by Shaun Harrison on 2/22/16.
//

public enum CompilationError: ErrorType {
    case Error(message: String)
    case UnknownError
}