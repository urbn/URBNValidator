//
//  URBNValidator.swift
//  URBNValidator
//
//  Created by Joseph Ridenour on 11/17/15.
//  Copyright © 2015 URBN. All rights reserved.
//

import Foundation


/**
 Validateable objects are meant to allow direct validation of keys/values of a given model by
 defining a validationMap which contains a map of keys -> ValidatingValue's
 */
public protocol Validateable {
    associatedtype V
    func validationMap() -> [String: ValidatingValue<V>]
}

/**
 This wraps up a value with it's list of rules to validate against.
 */
public struct ValidatingValue<V> {
    public var value: V?
    public var rules: [ValidationRule]
    
    public init(_ value: V?, rules: [ValidationRule]) {
        self.value = value
        self.rules = rules
    }
    
    public init(value: V?, rules: ValidationRule...) {
        self.init(value, rules: rules)
    }
}


/**
 # Validator
 
 This is our main validation protocol.  Any object that you want to be
 
 a validator, you can simply conform to this protocol and implement the initializer.
 
 
 By default we provide implementations for all of the properties and functions listed 
 
 here.
 */
public protocol Validator {
    
    /**
     This is used for building the localization key strings.  Takes the rule and the field
     currently being localized.  By default this generates `ls_URBNValidator_URBNValidator.{rule.localizationKey}`
     */
    var localizationKeyBuilder: (ValidationRule, String) -> String { get }
    
    /**
     You'll probably never need to override this unless you're using a specific bundle
     other than the bundle of this class.
     
     - note: We'll handle falling back to the mainBundle for any localizations for free, so
     you don't have to override this if you're just trying to localize with the main bundle
     */
    var localizationBundle: NSBundle { get }
    
    // You'll probably never use this.   But just incase here's a prop for it
    var localizationTable: String? { get }
    
    
    /**
     Designated initializer for validators. 
     
     -  parameter bundle: Optional `NSBundle` to use for localizations
    */
    init(bundle: NSBundle?)
    
    /**
     This validates a single value with a single rule.   The key is only used for display
     purposes.   It will be used to replace {{field}} in the localization.
     
     
     - parameters:
     - key: The key used to replace {{field}} in the localization
     - value: The value to validate with
     - rule: The rule to run the validation against
     
     - throws: An instance of NSError with the localized data
     */
    func validate<V>(key: String, value: V?, rule: ValidationRule) throws
    
    /**
     The purpose of this method is to validate the given model.   This will run through
     the model.validationMap and run validations on each one of the key -> Rules pairs.
     
     
     - parameters:
     - item: a validateable item to be used for validation
     - stopOnFirstError: indicates that you only care about the first error
     
     - throws: An instance of NSError representing the invalid data
     
     */
    func validate<V: Validateable>(item: V , stopOnFirstError: Bool) throws
    
    /**
     The purpose of this method is to validate the given model.   This will run through
     the model.validationMap and run validations on each one of the key -> Rules pairs.
     
     
     - parameters:
     - item: a validateable item to be used for validation
     - ignoreList: List of keys that should not be validated
     - stopOnFirstError: indicates that you only care about the first error
     
     - throws: An instance of NSError representing the invalid data
     
     */
    func validate<V: Validateable>(item: V, ignoreList: [String], stopOnFirstError: Bool) throws
    
    /**
     The purpose of this function is to wrap up our localization fallback logic, and handle
     replacing any values necessary in the result of the localized string
     
     - parameters:
     - rule: The validation rule to localize against
     - key: The key to inject into the localization (if applicable).  Replaces the {{field}}
     - value: The value to inject into the localization (if applicable).  Replaces the {{value}}
     */
    func localizeableString(rule: ValidationRule, key: String, value: Any?) -> String
}




private let DefaultBundle = NSBundle(identifier: "org.cocoapods.URBNValidator") ?? NSBundle.mainBundle()
private let DefaultLocalizationKeyBuilder: (ValidationRule, String) -> String = { rule, key in "ls_URBNValidator_URBNValidator.\(rule.localizationKey)" }

// MARK: - Default Implementations
extension Validator {
    
    public var localizationBundle: NSBundle { return DefaultBundle }
    public var localizationTable: String? { return nil }
    public var localizationKeyBuilder: (ValidationRule, String) -> String { return DefaultLocalizationKeyBuilder }
    
    public func validate<V>(key: String, value: V?, rule: ValidationRule) throws {
        if rule.validateValue(value) {
            return
        }
        
        throw NSError.fieldError(key, description: localizeableString(rule, key: key, value: value))
    }
    
    public func validate<V: Validateable>(item: V, stopOnFirstError: Bool = false) throws {
        do {
            try self.validate(item, ignoreList: [], stopOnFirstError: stopOnFirstError)
        } catch let e {
            throw e
        }
    }
    
    public func validate<V: Validateable>(item: V, ignoreList: [String], stopOnFirstError: Bool = false) throws {
        
        /// Nothing to validate here.   We're all good
        if item.validationMap().length == 0 { return }
        
        // We want to get our validationMap minus the items in the ignoreList
        let vdMap = item.validationMap().filter { !ignoreList.contains($0.0) }
        
        let errs = try vdMap.flatMap({ (key, value) -> [NSError]? in
            let rules = implicitelyRequiredRules(value.rules)
            
            return try rules.flatMap({ (rule) throws -> NSError? in
                do {
                    try validate(key, value: value.value, rule: rule)
                    return nil
                } catch let err as NSError {
                    if stopOnFirstError {
                        throw err
                    }
                    return err
                }
            })
        }).flatMap { $0 }
        
        if errs.count > 0 {
            throw NSError.multiErrorWithErrors(errs)
        }
    }
    
    public func localizeableString(rule: ValidationRule, key: String, value: Any?) -> String {
        let ruleKey = localizationKeyBuilder(rule, key)
        
        // First we try to localize against the mainBundle.
        let mainBundleStr = NSLocalizedString(ruleKey, tableName: self.localizationTable, comment: "")
        let str =  NSLocalizedString(mainBundleStr, tableName: self.localizationTable, bundle: self.localizationBundle, comment: "")
        
        // Now we're going to regex the resulting string and replace {{field}}, {{value}}
        var replacementValue: String = ""
        if let repValue = value as? CustomStringConvertible {
            replacementValue = repValue.description
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

    
    // MARK: - Internal -
    
    /**
     This takes an array of `ValidationRule` and inserts an URBNRequiredRule if necessary.
     If the list already contains a requirement rule (`URBNRequiredRule` or `URBNNotRequiredRule`),
     then we'll return the original list.   Otherwise, we'll add a requirement at the beginning
     of the list
     
     - parameter rules: The rules to do this implicit orchestration with
     
     - returns: The resulting rules to use for validation
     */
    internal func implicitelyRequiredRules(rules: [ValidationRule]) -> [ValidationRule] {
        
        // Sanity
        if rules.count == 0 {
            return rules
        }
        
        // If our rules do not contain any URBNRequirement rules, then
        // we can safely skip the next part
        if !rules.contains({ $0 is URBNRequirement}) {
            return rules
        }
        
        let isRequired = rules.contains({ $0 is URBNNotRequiredRule }) == false
        let hasRequirement = rules.contains({ $0 is URBNRequiredRule || $0 is URBNNotRequiredRule })
        let updatedRules = hasRequirement ? rules : ([URBNRequiredRule()] + rules)
        
        return updatedRules.map({ (r) -> ValidationRule in
            if var rr = r as? URBNRequirement {
                rr.isRequired = isRequired
            }
            
            return r
        })
    }
}


/**
 This is the main URBNValidator object.   Used to validate objects
 and localize the results in a nice way.
*/
// MARK: - URBNValidator -
public struct URBNValidator: Validator {
    
    public var localizationBundle: NSBundle = DefaultBundle
    public var localizationTable: String? = nil
    public var localizationKeyBuilder: (ValidationRule, String) -> String = DefaultLocalizationKeyBuilder
    
    public init(bundle: NSBundle? = nil) {
        if let bundle = bundle  {
            localizationBundle = bundle
        }
    }
}
