//
//  EquatableFormatter.swift
//  Equatable
//
//  Created by sergdort on 09/10/2016.
//  Copyright © 2016 sergdort. All rights reserved.
//

import Foundation
import XcodeKit

extension NSMutableArray {
    func castAtIdexTo<T>(_ type: T.Type) -> (Int) throws -> T {
        return { index in
            guard let casted = self[index] as? T else {
                throw EditorError.castError.nsError
            }
            return casted
        }
    }
}

func * (multiply: Int, str: String) -> String {
    return (0..<multiply).reduce(str) { (acum, _) -> String in
        return acum + str
    }
}

class EquatableGenerator {
    let buffer: XCSourceTextBuffer
    
    init(buffer: XCSourceTextBuffer) {
        self.buffer = buffer
    }
    
    func generate() throws {
        let newLines = try generateNewLines()
        self.buffer.lines.addObjects(from: newLines)
    }
    
    private func generateNewLines() throws -> [String] {
        let type = try generateTypeName()
        let body = try generateBody()
        
        return generateContent(with: type, body: body)
    }
    
    private func generateTypeName() throws -> String {
        guard let selection = self.buffer.selections.firstObject as? XCSourceTextRange else {
            throw EditorError.missingSelection.nsError
        }
        let firsLine = try self.buffer.lines.castAtIdexTo(String.self)(selection.start.line)
        return try Scanner.scanTypeName(line: firsLine)
    }
    
    private func generateBody() throws -> [String] {
        let variables = try generateVariables()
        let indent = String(repeating: " ", count: self.buffer.indentationWidth)
        if variables.isEmpty {
            return []
        }
        if variables.count == 1 {
            return variables
                .map {
                    return 2 * indent + "return lhs.\($0) == rhs.\($0)\n"
                }
            
        }
        return variables.enumerated().map { (offset, item) -> String in
            if offset == 0 {
                return 2 * indent + "return lhs.\(item) == rhs.\(item) &&"
            }
            if offset == variables.count - 1 {
                return 3 * indent + "lhs.\(item) == rhs.\(item)"
            }
            return 3 * indent + "lhs.\(item) == rhs.\(item) && \n"
        }
    }
    
    private func generateContent(with typeName: String, body: [String]) -> [String] {
        let indent = String(repeating: " ", count: self.buffer.indentationWidth)
        let newLine = "\n"
        let extensionStart = "extension \(typeName): Equatable {\n"
        let funcStart = indent + "static func == (lhs: \(typeName), rhs: \(typeName)) -> Bool {\n"
        let funcEnd = indent + "}\n"
        let extensionEnd = "}\n"
        
        return [newLine] + [extensionStart] + [funcStart] + body + [funcEnd] + [extensionEnd]
    }
    
    private func generateVariables() throws -> [String] {
        guard let selection = self.buffer.selections.firstObject as? XCSourceTextRange else {
            throw EditorError.missingSelection.nsError
        }
        let start = selection.start.line + 1
        let end = selection.end.line
        let selectionRange = start...end
        
        return try selectionRange
            .map(buffer.lines.castAtIdexTo(String.self))
            .filter(isNotEmptyLine)
            .flatMap(Scanner.scanVariableName)
    }
    
    private func isNotEmptyLine(_ line: String) throws -> Bool {
        let expression = try NSRegularExpression(pattern: " *\n", options: [])
        let range = NSRange(location: 0, length: line.characters.count)
        let replaced = expression.stringByReplacingMatches(in: line,
                                                           options: [],
                                                           range: range,
                                                           withTemplate: "")
        return !replaced.isEmpty
    }
}
