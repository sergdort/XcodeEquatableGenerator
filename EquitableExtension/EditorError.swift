//
//  EditorError.swift
//  Equitable
//
//  Created by sergdort on 09/10/2016.
//  Copyright © 2016 sergdort. All rights reserved.
//

import Foundation

enum EditorError {
    case missingSelection
    case parseError
    case castError
    
    private var message: String {
        switch self {
        case .missingSelection:
            return "Missing selection"
        case .parseError:
            return "Parse error"
        case .castError:
            return "Cast error"
        }
    }
    
    var nsError: NSError {
        return NSError(domain: "com.sergdort.EquitableExtension",
                       code: -1,
                       userInfo: [NSLocalizedDescriptionKey: message])
    }
}

