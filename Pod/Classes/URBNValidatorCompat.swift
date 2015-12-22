
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
    
    /**
     Used to validate a single @value with the given rule.
     If invalid, then will `throw` an error with the localized reason
     why the value failed
     **/
    func validate(key: String?, value: AnyObject?, rule: CompatBaseRule) throws
    func validate(item: CompatValidateable , stopOnFirstError: Bool) throws
}

@objc public protocol CompatValidateable {
    func validationMap() -> [String: CompatValidatingValue]
}

extension CompatValidateable {
    func mapBack() -> [String: ValidatingValue] {
        return validationMap().reduce([String: ValidatingValue]()) { (var dict, items: (key: String, value: CompatValidatingValue)) -> [String: ValidatingValue] in
            dict[items.key] = items.value.mapBack()
            return dict
        }
    }
}

@objc public class URBNCompatValidator: NSObject, CompatValidator {
    private let backingValidator: URBNValidator = URBNValidator()
    
    public var localizationBundle: NSBundle {
        return backingValidator.localizationBundle
    }
    
    public func validate(key: String?, value: AnyObject?, rule: CompatBaseRule) throws {
        try backingValidator.validate(key, value: value, rule: rule.baseRule)
    }
    
    public func validate(item: CompatValidateable , stopOnFirstError: Bool) throws {
        try backingValidator.validate(ConvertCompat(cv: item), stopOnFirstError: stopOnFirstError)
    }
}

class ConvertCompat: Validateable {
    typealias T = AnyObject
    var rules = [String: ValidatingValue]()
    
    init(cv: CompatValidateable) {
        rules = cv.mapBack()
    }
    
    func validationMap() -> [String : ValidatingValue] {
        return rules
    }
}

@objc public class CompatValidatingValue: NSObject {
    public var value: AnyObject?
    public var rules: [CompatBaseRule]
    
    public init(_ value: AnyObject?, rules: [CompatBaseRule]) {
        self.value = value
        self.rules = rules
        super.init()
    }
    
    public convenience init(value: AnyObject?, rules: CompatBaseRule...) {
        self.init(value, rules: rules)
    }
}

extension CompatValidatingValue {
    func mapBack() -> ValidatingValue {
        let mrules = rules.map { (rule) -> ValidationRule in
            return rule.baseRule
        }
        let v = ValidatingValue(value, rules: mrules)
        
        return v
    }
}