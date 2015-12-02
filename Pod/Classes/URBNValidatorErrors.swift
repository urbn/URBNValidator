//
//  URBNValidatorErrors.swift
//  URBNValidator
//
//  Created by Joseph Ridenour on 12/2/15.
//
//

import Foundation


public enum ErrorDomains: String {
    case ValidationError
    case MultiValidationError
}

public extension NSError {
    
    public var isMultiError: Bool {
        get {
            return self.domain == ErrorDomains.MultiValidationError.rawValue
        }
    }
    
    public var underlyingErrors: [NSError]? {
        get {
            if !self.isMultiError { return nil }
            return self.userInfo["multi_errors"] as? [NSError]
        }
    }
    
    class func multiErrorWithErrors(errors: [NSError]) -> NSError {
        let userInfo: [NSObject: AnyObject] = [
            NSLocalizedDescriptionKey: "Multiple errors occurred",
            "multi_errors": errors
        ]
        
        return NSError(domain: ErrorDomains.MultiValidationError.rawValue, code: 500, userInfo: userInfo)
    }
}