
//
//  URBNValidatorCompat.swift
//  Pods
//
//  Created by Nick DiStefano on 12/21/15.
//
//

import Foundation


@objc public protocol CompatValidator {
    var localizationBundle: NSBundle { get }

    func validate(key: String?, value: AnyObject?, rule: URBNCompatBaseRule) throws
    func validate(item: CompatValidateable , stopOnFirstError: Bool) throws
}

@objc public protocol CompatValidateable {
    func validationMap() -> [String: CompatValidatingValue]
}

extension CompatValidateable {
    func backingValidationMap() -> [String: ValidatingValue] {
        return validationMap().reduce([String: ValidatingValue]()) { (var dict, items: (key: String, value: CompatValidatingValue)) -> [String: ValidatingValue] in
            dict[items.key] = items.value.backingRules()
            return dict
        }
    }
}

@objc public class URBNCompatValidator: NSObject, CompatValidator {
    private let backingValidator: URBNValidator = URBNValidator()
    
    public var localizationBundle: NSBundle {
        return backingValidator.localizationBundle
    }
    
    public func validate(key: String?, value: AnyObject?, rule: URBNCompatBaseRule) throws {
        try backingValidator.validate(key, value: value, rule: rule.backingRule)
    }
    
    public func validate(item: CompatValidateable , stopOnFirstError: Bool) throws {
        try backingValidator.validate(ConvertCompat(cv: item), stopOnFirstError: stopOnFirstError)
    }
}

class ConvertCompat: Validateable {
    var rules = [String: ValidatingValue]()
    
    init(cv: CompatValidateable) {
        rules = cv.backingValidationMap()
    }
    
    func validationMap() -> [String : ValidatingValue] {
        return rules
    }
}

@objc public class CompatValidatingValue: NSObject {
    public var value: AnyObject?
    public var rules: [URBNCompatBaseRule]
    
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
    func backingRules() -> ValidatingValue {
        let mrules = rules.map { $0.backingRule as ValidationRule }
        let v = ValidatingValue(value, rules: mrules)
        
        return v
    }
}