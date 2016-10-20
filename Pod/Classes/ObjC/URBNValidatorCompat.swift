
//
//  URBNValidatorCompat.swift
//  URBNValidator
//
//  Created by Nick DiStefano on 12/21/15.
//
//

import Foundation


@objc public protocol CompatValidator {
    var localizationBundle: Bundle { get }

    func validateKey(_ key: String, withValue value: AnyObject?, rule: URBNCompatBaseRule) throws
    func validate(_ item: CompatValidateable , stopOnFirstError: Bool) throws
}

@objc public protocol CompatValidateable {
    func validationMap() -> [String: CompatValidatingValue]
}

extension CompatValidateable {
    func backingValidationMap() -> [String: ValidatingValue<AnyObject>] {
        return validationMap().reduce([String: ValidatingValue<AnyObject>]()) { (dict, items: (key: String, value: CompatValidatingValue)) -> [String: ValidatingValue<AnyObject>] in
            var dictionary = dict
            dictionary[items.key] = items.value.backingRules()
            return dictionary
        }
    }
}

@objc open class URBNCompatValidator: NSObject, CompatValidator {
    fileprivate var backingValidator: URBNValidator = URBNValidator(bundle: Bundle(for: URBNCompatValidator.self))
    
    open var localizationBundle: Bundle {
        get {
            return backingValidator.localizationBundle
        }
        set {
            backingValidator.localizationBundle = newValue
        }
    }
    
    open func validateKey(_ key: String, withValue value: AnyObject?, rule: URBNCompatBaseRule) throws {
        try backingValidator.validate(key, value: value, rule: rule.backingRule)
    }
    
    open func validate(_ item: CompatValidateable , stopOnFirstError: Bool) throws {
        try backingValidator.validate(ConvertCompat(cv: item), stopOnFirstError: stopOnFirstError)
    }
}

class ConvertCompat: Validateable {
    typealias V = AnyObject
    var rules = [String: ValidatingValue<V>]()
    
    init(cv: CompatValidateable) {
        rules = cv.backingValidationMap()
    }
    
    func validationMap() -> [String : ValidatingValue<V>] {
        return rules
    }
}

@objc open class CompatValidatingValue: NSObject {
    open var value: AnyObject?
    open var rules: [URBNCompatBaseRule]
    
    public init(_ value: AnyObject?, rules: [URBNCompatBaseRule]) {
        self.value = value
        self.rules = rules
        super.init()
    }
    
    public convenience init(value: AnyObject?, rules: URBNCompatBaseRule...) {
        self.init(value, rules: rules)
    }
}

extension CompatValidatingValue {
    func backingRules() -> ValidatingValue<AnyObject> {
        let mrules = rules.map { $0.backingRule as ValidationRule }
        let v = ValidatingValue(value, rules: mrules)
        
        return v
    }
}
