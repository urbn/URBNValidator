//
//  URBNValidator.swift
//  URBNValidator
//
//  Created by Joseph Ridenour on 11/17/15.
//  Copyright © 2015 URBN. All rights reserved.
//

import Foundation


public class ValidatingValue<T, V: ValidationRule> {
    public var value: T?
    public var rules: [V]
    
    public init(_ value: T?, rules: [V]) {
        self.value = value
        self.rules = rules
    }
    
    public convenience init(value: T?, rules: V...) {
        self.init(value, rules: rules)
    }
}

@objc public class CompatValidatingValue: NSObject {
    public var value: AnyObject?
    public var rules: [OCValidationRule]
    
    public init(_ value: AnyObject?, rules: [OCValidationRule]) {
        self.value = value
        self.rules = rules
        super.init()
    }
    
    public convenience init(value: AnyObject?, rules: OCValidationRule...) {
        self.init(value, rules: rules)
    }
}

extension CompatValidatingValue {
    func mapBack() -> ValidatingValue<AnyObject, MapBackRule> {
        let mrules = rules.map( { MapBackRule(backingOCRule: $0) })
        let v = ValidatingValue(value, rules: mrules)
        
        return v
    }
}

public protocol Validator {
    var localizationBundle: NSBundle { get }
    
    /**
     Used to validate a single @value with the given rule.
     If invalid, then will `throw` an error with the localized reason
     why the value failed
    **/
    typealias ValT
    func validate<V: ValidationRule where V.VR == ValT>(key: String?, value: ValT?, rule: V) throws
    func validate<Vable: Validateable where Vable.T == ValT, Vable.V.VR == ValT>(item: Vable , stopOnFirstError: Bool) throws
}

@objc public protocol CompatValidator {
    var localizationBundle: NSBundle { get }
    
    /**
     Used to validate a single @value with the given rule.
     If invalid, then will `throw` an error with the localized reason
     why the value failed
     **/
    func validate(key: String?, value: AnyObject?, rule: OCValidationRule) throws
    func validate(item: CompatValidateable , stopOnFirstError: Bool) throws
}

@objc public protocol CompatValidateable {
    func validationMap() -> [String: CompatValidatingValue]
}

extension CompatValidateable {
    func mapBack() -> [String: ValidatingValue<AnyObject, MapBackRule>] {
        return validationMap().reduce([String: ValidatingValue<AnyObject, MapBackRule>]()) { (var dict, items: (key: String, value: CompatValidatingValue)) -> [String: ValidatingValue<AnyObject, MapBackRule>] in
            dict[items.key] = items.value.mapBack()
            return dict
        }
    }
}

@objc public class URBNCompatValidator: NSObject, CompatValidator {
    private let backingValidator: URBNValidator<AnyObject> = URBNValidator<AnyObject>()
    
    public var localizationBundle: NSBundle {
        return backingValidator.localizationBundle
    }
    
    public func validate(key: String?, value: AnyObject?, rule: OCValidationRule) throws {
        try backingValidator.validate(key, value: value, rule: MapBackRule(backingOCRule: rule))
    }
    
    public func validate(item: CompatValidateable , stopOnFirstError: Bool) throws {
        try backingValidator.validate(ConvertCompat(cv: item), stopOnFirstError: stopOnFirstError)
    }
}
class ConvertCompat: Validateable {
    typealias T = AnyObject
    typealias V = MapBackRule
    var rules = [String: ValidatingValue<T, V>]()
    
    init(cv: CompatValidateable) {
        rules = cv.mapBack()
    }
    
    func validationMap() -> [String : ValidatingValue<T, V>] {
        return rules
    }
}
/**
 Validateable objects are meant to allow direct validation of keys/values of a given model by 
 defining a validationMap which contains a map of keys -> ValidatingValue's
*/
public protocol Validateable {
    typealias T
    typealias V: ValidationRule
    func validationMap() -> [String: ValidatingValue<T, V>]
}

/**
 This is the main URBNValidator object.   Used to validate objects
 and localize the results in a nice way.
*/
// MARK: - URBNValidator -
public class URBNValidator<T>: Validator {
    public typealias ValT = T
    public init() {}
    // MARK: - Properties -
    
    // You'll probably never use this.   But just incase here's a prop for it
    public var localizationTable: String?
    
    /**
     You'll probably never need to override this unless you're using a specific bundle
     other than the bundle of this class.
     
     - note: We'll handle falling back to the mainBundle for any localizations for free, so
     you don't have to override this if you're just trying to localize with the main bundle
     */
    public var localizationBundle: NSBundle = NSBundle(forClass: URBNValidator<T>.self)
    
    
    
    // MARK: - Validations -
    
    /**
     This validates a single value with a single rule.   The key is only used for display
     purposes.   It will be used to replace {{field}} in the localization.
     
    
     - parameters:
        - key: The key used to replace {{field}} in the localization
        - value: The value to validate with
        - rule: The rule to run the validation against
     
     - throws: An instance of NSError with the localized data
    */
    public func validate<V: ValidationRule where V.VR == T>(key: String? = nil, value: T?, rule: V) throws {
        if rule.validateValue(value) {
            return
        }
        
        throw NSError.fieldError(key, description: localizeableString(rule, key: key, value: value))
    }
    
    
    
    /**
     The purpose of this method is to validate the given model.   This will run through
     the model.validationMap and run validations on each one of the key -> Rules pairs. 
     
     
     - parameters:
        - item: a validateable item to be used for validation
        - stopOnFirstError: indicates that you only care about the first error
     
     - throws: An instance of NSError representing the invalid data
     
    */
    public func validate<Vable: Validateable where Vable.T == T, Vable.V.VR == T>(item: Vable, stopOnFirstError: Bool = false) throws {
        do {
            try self.validate(item, ignoreList: [], stopOnFirstError: stopOnFirstError)
        } catch let e {
            throw e
        }
    }
    
    /**
     The purpose of this method is to validate the given model.   This will run through
     the model.validationMap and run validations on each one of the key -> Rules pairs.
     
     
     - parameters:
     - item: a validateable item to be used for validation
     - ignoreList: List of keys that should not be validated
     - stopOnFirstError: indicates that you only care about the first error
     
     - throws: An instance of NSError representing the invalid data
     
     */
    public func validate<Vable: Validateable where Vable.T == T, Vable.V.VR == T>(item: Vable, ignoreList: [String], stopOnFirstError: Bool = false) throws {
        
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
    
    
    
    // MARK: - Internal -
    
    /**
    The purpose of this function is to wrap up our localization fallback logic, and handle
    replacing any values necessary in the result of the localized string
    
    - parameters:
        - rule: The validation rule to localize against
        - key: The key to inject into the localization (if applicable).  Replaces the {{field}}
        - value: The value to inject into the localization (if applicable).  Replaces the {{value}}
    */
    internal func localizeableString<T, V: ValidationRule>(rule: V, key: String?, value: T?) -> String {
        let ruleKey = "ls_URBNValidator_\(rule.localizationKey)"
        
        // First we try to localize against the mainBundle.
        let mainBundleStr = NSLocalizedString(ruleKey, tableName: self.localizationTable, comment: "")
        let str =  NSLocalizedString(mainBundleStr, tableName: self.localizationTable, bundle: self.localizationBundle, comment: "")
        
        // Now we're going to regex the resulting string and replace {{field}}, {{value}}
        var replacementValue: String = ""
        if (value != nil && value is CustomStringConvertible) {
            replacementValue = ""//value!.description
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
    
    /**
     This takes an array of `ValidationRule` and inserts an URBNRequiredRule if necessary.
     If the list already contains a requirement rule (`URBNRequiredRule` or `URBNNotRequiredRule`),
     then we'll return the original list.   Otherwise, we'll add a requirement at the beginning
     of the list
     
     - parameter rules: The rules to do this implicit orchestration with
     
     - returns: The resulting rules to use for validation
     */
    internal func implicitelyRequiredRules<V: ValidationRule>(rules: [V]) -> [V] {
        
        // Sanity
        if rules.count == 0 {
            return rules
        }
        
        // If our rules do not contain any URBNRequirement rules, then
        // we can safely skip the next part
        if !rules.contains({ $0 is URBNRequirement}) {
            return rules
        }
        
        let isRequired = rules.contains({ $0 is URBNNotRequiredRule<T> }) == false
        let hasRequirement = rules.contains({ $0 is URBNRequiredRule<T> || $0 is URBNNotRequiredRule<T> })
        let updatedRules = hasRequirement ? rules : ([URBNRequiredRule<T>() as! V] + rules)
        
        return updatedRules.map({ (r) -> V in
            if var rr = r as? URBNRequirement {
                rr.isRequired = isRequired
            }
            
            return r
        })
    }
}


