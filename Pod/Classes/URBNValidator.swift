//
//  URBNValidator.swift
//  URBNValidator
//
//  Created by Joseph Ridenour on 11/17/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
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

@objc public protocol Validator {
    func localizationBundle() -> NSBundle
    func validate(item: Validateable, stopOnFirstError: Bool) throws
}

@objc public protocol Validateable {
    
    func validationMap() -> [String: [ValidationRule]]
    func valueForKey(key: String) -> AnyObject?
}

public class URBNValidator: NSObject, Validator {
    var localizationTable: String?
    
    
    @objc public func localizationBundle() -> NSBundle {
        return NSBundle(forClass: URBNValidator.self)
    }
    
    /**
    The purpose of this function is to wrap up our localization fallback logic, and handle
    replacing any values necessary in the result of the localized string 
    */
    func localizeableString(rule: ValidationRule, key: String, value: AnyObject?) -> String {
        let ruleKey = "ls_URBNValidator_\(rule.localizationKey)"
        
        // First we try to localize against the mainBundle.
        let mainBundleStr = NSLocalizedString(ruleKey, tableName: self.localizationTable, comment: "")
        let str =  NSLocalizedString(mainBundleStr, tableName: self.localizationTable, bundle: self.localizationBundle(), value: "", comment: "")
        
        // Now we're going to regex the resulting string and replace {{field}}, {{value}}
        var replacementValue: String = ""
        if (value != nil && value is CustomStringConvertible) {
            replacementValue = value!.description
        }
        let options: NSRegularExpressionOptions = [NSRegularExpressionOptions.CaseInsensitive]
        return [
            // Considering the try! fine here because this is a dev issue.   If you write an invalid 
            // regex, then that's your own fault.   Once it's written properly it's guaranteed to not crash
            key: try! NSRegularExpression(pattern: "\\{\\{field\\}\\}", options: options),
            replacementValue: try! NSRegularExpression(pattern: "\\{\\{value\\}\\}", options: options),
        ].reduce(str) { (s, replacement: (key: String, pattern: NSRegularExpression)) -> String in
            return replacement.pattern.stringByReplacingMatchesInString(s,
                options: .ReportCompletion,
                range: NSMakeRange(0, s.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)),
                withTemplate: replacement.key
            )
        }
    }
    
    public func validate(item: Validateable, stopOnFirstError: Bool = false) throws {
        
        /// Nothing to validate here.   We're all good
        if item.validationMap().count == 0 { return }
        
        var errs: [NSError] = [NSError]()
        for (key, rules) in item.validationMap() {
            let value = item.valueForKey(key)
            for rule in rules {
                if rule.validateValue(value) { continue }
                
                let err = NSError(domain: ErrorDomains.ValidationError.rawValue, code: 200, userInfo: [NSLocalizedDescriptionKey: localizeableString(rule, key: key, value: value)])
                if stopOnFirstError {
                    throw err
                }
                else {
                    errs.append(err)
                }
            }
        }
        
        if errs.count > 0 {
            throw NSError.multiErrorWithErrors(errs)
        }
    }
}