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
private let kFieldMetaDataInfoKey = "com.urbnvalidator.metadata"

class ErrorMeta {
    var field: String?
    
    init(field: String?) {
        self.field = field
    }
}

public extension NSError {
    
    /**
     Helper to check if this error is a multiError
    */
    public var isMultiError: Bool {
        // Make sure we're referencing one of our error domains
        guard self.domain == ValidationError._NSErrorDomain else { return false }
        return self.code == ValidationError.MultiFieldInvalid.rawValue
    }
    
    public var underlyingErrors: [NSError]? {
        if !self.isMultiError { return nil }
        return self.userInfo[kMultiErrorUserInfoKey] as? [NSError]
    }
    
    public var vdMetaFieldName: String? {
        return self.validationMeta?.field
    }
    
    internal var validationMeta: ErrorMeta? {
        return self.userInfo[kFieldMetaDataInfoKey] as? ErrorMeta
    }
    
    
    // MARK: - Helpers
    internal class func fieldError(field: String?, description: String) -> NSError {
        let userInfo: [NSObject: AnyObject] = [
            NSLocalizedDescriptionKey: description,
            kFieldMetaDataInfoKey: ErrorMeta(field: field)
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