
//
//  URBNValidationRulesCompat.swift
//  Pods
//
//  Created by Nick DiStefano on 12/21/15.
//
//

import Foundation

@objc public protocol OCValidationRule {
    var localizationKey: String { get set }
    func validateValue(value: AnyObject?) -> Bool
    func validateValue(value: AnyObject?, key: String) -> Bool
}

@objc public class CompatBaseRule: NSObject, OCValidationRule {
    var baseRule: URBNBaseRule
    
    public init(localizationKey: String? = nil) {
        baseRule = URBNBaseRule(localizationKey: localizationKey)
        super.init()
    }
    
    public func validateValue(value: AnyObject?) -> Bool { return baseRule.validateValue(value) }
    public func validateValue(value: AnyObject?, key: String) -> Bool { return baseRule.validateValue(value, key: key) }
    public var localizationKey: String  {
        get {
            return baseRule.localizationKey
        }
        set {
            baseRule.localizationKey = newValue
        }
    }
}

@objc public class CompatRegexRule: CompatBaseRule, URBNRequirement {
    public var isRequired: Bool {
        get {
            if let requiredBaseRule = self.baseRule as? URBNRegexRule {
                return requiredBaseRule.isRequired
            }
            
            return false
        }
        set {
            if let requiredBaseRule = self.baseRule as? URBNRegexRule {
                requiredBaseRule.isRequired = newValue
            }
        }
    }
    
    public init(pattern: String, localizationKey: String? = nil) {
        super.init()
        self.baseRule = URBNRegexRule(pattern: pattern, localizationKey: localizationKey)
    }
}

@objc public class CompatRequiredRule: CompatBaseRule {
    public override init(localizationKey: String? = nil) {
        super.init(localizationKey: localizationKey)
        self.baseRule = URBNRequiredRule()
    }
}

@objc public class CompatNotRequiredRule: CompatBaseRule {
    public override init(localizationKey: String? = nil) {
        super.init(localizationKey: localizationKey)
        self.baseRule = URBNNotRequiredRule()
    }
}

@objc public class CompatBlockRule: CompatBaseRule {
    public typealias CompatBlockValidation = (value: AnyObject?) -> Bool
    
    public init(_ validator: BlockValidation) {
        super.init()
        let blockRule = URBNBlockRule(validator)
        blockRule.blockValidation = validator
        self.baseRule = blockRule
    }
    public init(validator: BlockValidation, localizationKey: String? = nil) {
        super.init(localizationKey: localizationKey)
        let blockRule = URBNBlockRule(validator: validator, localizationKey: localizationKey)
        blockRule.blockValidation = validator
        self.baseRule = blockRule
    }
    public convenience init(validator: CompatBlockValidation, localizationKey: String?) {
        let valB = { (v: Any?) -> Bool in
            if let anyObjectv = v as? AnyObject {
                return validator(value: anyObjectv)
            }
            
            return false
        }
        
        self.init(validator: valB, localizationKey: localizationKey)
    }
}