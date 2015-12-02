//
//  URBNValidator.swift
//  URBNValidator
//
//  Created by Joseph Ridenour on 11/17/15.
//  Copyright © 2015 CocoaPods. All rights reserved.
//

import Foundation


@objc public class ValidatingValue: NSObject {
    public var value: AnyObject?
    public var rules: [ValidationRule]
    
    public init(_ value: AnyObject?, rules: [ValidationRule]) {
        self.value = value
        self.rules = rules
        super.init()
    }
    
    public convenience init(value: AnyObject?, rules: ValidationRule...) {
        self.init(value, rules: rules)
    }
}

@objc public protocol Validator {
    func localizationBundle() -> NSBundle
    /**
     Used to validate a single @value with the given rule.
     If invalid, then will `throw` an error with the localized reason
     why the value failed
    **/
    func validate(key: String?, value: AnyObject?, rule: ValidationRule) throws
    func validate(item: Validateable, stopOnFirstError: Bool) throws
}

@objc public protocol Validateable {
    func validationMap() -> [String: ValidatingValue]
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
    func localizeableString(rule: ValidationRule, key: String?, value: AnyObject?) -> String {
        let ruleKey = "ls_URBNValidator_\(rule.localizationKey)"
        
        // First we try to localize against the mainBundle.
        let mainBundleStr = NSLocalizedString(ruleKey, tableName: self.localizationTable, comment: "")
        print("Main Bundle: ", mainBundleStr)
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
            (key ?? " "): try! NSRegularExpression(pattern: "\\{\\{field\\}\\}", options: options),
            replacementValue: try! NSRegularExpression(pattern: "\\{\\{value\\}\\}", options: options),
        ].reduce(str) { (s, replacement: (key: String, pattern: NSRegularExpression)) -> String in
            return replacement.pattern.stringByReplacingMatchesInString(s,
                options: .ReportCompletion,
                range: NSMakeRange(0, s.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)),
                withTemplate: replacement.key
            )
        }
    }
    
    public func validate(key: String? = nil, value: AnyObject?, rule: ValidationRule) throws {
        if rule.validateValue(value) {
            return
        }
        
        throw NSError(domain: ErrorDomains.ValidationError.rawValue, code: 200, userInfo: [NSLocalizedDescriptionKey: localizeableString(rule, key: key, value: value)])
    }
    
    public func validate(item: Validateable, stopOnFirstError: Bool = false) throws {
        
        /// Nothing to validate here.   We're all good
        if item.validationMap().count == 0 { return }
        
        var errs: [NSError] = [NSError]()
        for (key, v) in item.validationMap() {
            let value = v.value;
            for rule in v.rules {
                
                do {
                    try validate(key, value: value, rule: rule)
                } catch let err as NSError {
                    if stopOnFirstError {
                        throw err
                    } else {
                        errs.append(err)
                    }
                }
            }
        }
        
        if errs.count > 0 {
            throw NSError.multiErrorWithErrors(errs)
        }
    }
}