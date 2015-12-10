//
//  URBNValidatorErrors.swift
//  URBNValidator
//
//  Created by Joseph Ridenour on 12/2/15.
//
//

import Foundation


/**
 This is our type of validation errors that we can have
 
 *Values*
 
 `FieldInvalid` There is only one invalid field
 `MultiFieldInvalid` There are multiple invalid fields
*/
@objc public enum ValidationError: Int, ErrorType {
    // Swift namespaces this error when it generates the constant. 
    // So if we don't provide that same thing here, then our domain const would
    // differ from what we actually send in the domain. 😢
    public static var _NSErrorDomain = "URBNValidator.ValidationError"
    case FieldInvalid
    case MultiFieldInvalid
}

private let kMultiErrorUserInfoKey = "multi_errors"

public extension NSError {
    
    /**
     Helper to check if this error is a multiError
    */
    public var isMultiError: Bool {
        get {
            // Make sure we're referencing one of our error domains
            guard self.domain == ValidationError._NSErrorDomain else { return false }
            return self.code == ValidationError.MultiFieldInvalid.rawValue
        }
    }
    
    public var underlyingErrors: [NSError]? {
        get {
            if !self.isMultiError { return nil }
            return self.userInfo[kMultiErrorUserInfoKey] as? [NSError]
        }
    }
    
    
    // MARK: - Helpers
    internal class func fieldError(description: String) -> NSError {
        let userInfo: [NSObject: AnyObject] = [
            NSLocalizedDescriptionKey: description
        ]
        
        return NSError(domain: ValidationError._NSErrorDomain, code: ValidationError.FieldInvalid.rawValue, userInfo: userInfo)
    }
    
    internal class func multiErrorWithErrors(errors: [NSError]) -> NSError {
        let userInfo: [NSObject: AnyObject] = [
            NSLocalizedDescriptionKey: "Multiple errors occurred",
            kMultiErrorUserInfoKey: errors
        ]
        
        return NSError(domain: ValidationError._NSErrorDomain, code: ValidationError.MultiFieldInvalid.rawValue, userInfo: userInfo)
    }
}