//
//  URBNValidator.swift
//  URBNValidator
//
//  Created by Joseph Ridenour on 11/17/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Foundation


@objc public protocol Validator {
    func localizationBundle() -> NSBundle
    func validateValue(value: AnyObject?, rules: [ValidationRule]) -> NSError?
}


public class URBNValidator: NSObject, Validator {
    var localizationTable: String?
    
    
    @objc public func localizationBundle() -> NSBundle {
        return NSBundle.mainBundle()
    }
    
    @objc public func validateValue(value: AnyObject?, rules: [ValidationRule]) -> NSError? {
        
        for r in rules {
            guard r.validateValue(value) else {
                
                // TODO:  Make this not stupid
                let e = NSError(domain: "URBNValidator", code: 500, userInfo: [
                    NSLocalizedDescriptionKey: NSLocalizedString(r.localizationKey, tableName: self.localizationTable, bundle: localizationBundle(), value: "Required", comment: "")
                    ])
                return e
            }
        }
        
        return nil
    }
}