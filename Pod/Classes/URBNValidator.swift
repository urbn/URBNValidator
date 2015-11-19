//
//  URBNValidator.swift
//  URBNValidator
//
//  Created by Joseph Ridenour on 11/17/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Foundation

@objc public protocol ValidationRule {
    var localizationKey: String { get set }
    func validateValue(value: AnyObject?) -> Bool
}

@objc public protocol Validator {
    func localizationBundle() -> NSBundle
    func validateValue(value: AnyObject?, rules: [ValidationRule]) -> NSError?
}


public class URBNRequiredRule: NSObject, ValidationRule {
    @objc public var localizationKey = "URBNRequiredRule"
    
    @objc public func validateValue(value: AnyObject?) -> Bool {
        return value != nil
    }
}


public class URBNValidator: NSObject, Validator {
    var localizationTable: String?
    
    
    @objc public func localizationBundle() -> NSBundle {
        return NSBundle.mainBundle()
    }
    
    @objc public func validateValue(value: AnyObject?, rules: [ValidationRule]) -> NSError? {
        
        for r in rules {
            guard r.validateValue(value) else {
                
                let e = NSError(domain: "URBNValidator", code: 500, userInfo: [
                    NSLocalizedDescriptionKey: NSLocalizedString(r.localizationKey, tableName: self.localizationTable, bundle: localizationBundle(), value: "Required", comment: "")
                    ])
                return e
            }
        }
        
        return nil
    }
}