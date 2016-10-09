//
//  SourceEditorCommand.swift
//  EquitableExtension
//
//  Created by sergdort on 08/10/2016.
//  Copyright © 2016 sergdort. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: @escaping (Error?) -> Void ) -> Void {
        
        let formatter = EquatableFormatter(buffer: invocation.buffer)
        do {
            try formatter.formatt()
            completionHandler(nil)
        } catch {
            completionHandler(error)
        }
    }
    
}

