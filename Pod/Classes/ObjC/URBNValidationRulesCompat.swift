
//
//  URBNValidationRulesCompat.swift
//  Pods
//
//  Created by Nick DiStefano on 12/21/15.
//
//

import Foundation


@objc public class URBNCompatBaseRule: NSObject {
    var backingRule: URBNBaseRule
    
    public init(localizationKey: String? = nil) {
        backingRule = URBNBaseRule(localizationKey: localizationKey)
        super.init()
    }
    
    public func validateValue(value: AnyObject?) -> Bool { return backingRule.validateValue(value) }
    
    public func validateValue(value: AnyObject?, key: String) -> Bool { return backingRule.validateValue(value, key: key) }
    
    public var localizationKey: String  {
        get {
            return backingRule.localizationKey
        }
        set {
            backingRule.localizationKey = newValue
        }
    }
}

@objc public class URBNCompatRequirementRule: URBNCompatBaseRule, URBNRequirement {
    public var isRequired: Bool {
        get {
            if let requiredBaseRule = backingRule as? URBNRequirement {
                return requiredBaseRule.isRequired
            }
            
            return false
        }
        set {
            if var requiredBaseRule = backingRule as? URBNRequirement {
                requiredBaseRule.isRequired = newValue
            }
        }
    }
}

@objc public class URBNCompatRegexRule: URBNCompatRequirementRule {
    public init(pattern: String, localizationKey: String? = nil) {
        super.init()
        backingRule = URBNRegexRule(pattern: pattern, localizationKey: localizationKey)
    }
}

@objc public class URBNCompatRequiredRule: URBNCompatBaseRule {
    public override init(localizationKey: String? = nil) {
        super.init(localizationKey: localizationKey)
        backingRule = URBNRequiredRule()
    }
}

@objc public class URBNCompatNotRequiredRule: URBNCompatBaseRule {
    public override init(localizationKey: String? = nil) {
        super.init(localizationKey: localizationKey)
        backingRule = URBNNotRequiredRule()
    }
}

@objc public class URBNCompatBlockRule: URBNCompatBaseRule {
    public typealias CompatBlockValidation = (value: AnyObject?) -> Bool
    
    public init(_ validator: BlockValidation) {
        super.init()
        let blockRule = URBNBlockRule(validator)
        blockRule.blockValidation = validator
        backingRule = blockRule
    }
    
    public init(validator: BlockValidation, localizationKey: String? = nil) {
        super.init(localizationKey: localizationKey)
        let blockRule = URBNBlockRule(validator: validator, localizationKey: localizationKey)
        blockRule.blockValidation = validator
        backingRule = blockRule
    }
    
    public convenience init(validator: CompatBlockValidation, localizationKey: String?) {
        let compatWrappingBlock = { (anyValue: Any?) -> Bool in
            if let anyObjectValue = anyValue as? AnyObject {
                return validator(value: anyObjectValue)
            }
            
            return false
        }
        
        self.init(validator: compatWrappingBlock, localizationKey: localizationKey)
    }
}

@objc public class URBNCompatDateRule: URBNCompatBaseRule {
    
    public init(comparisonType: URBNDateComparision = .Past, localizationKey: String? = nil) {
        super.init()
        backingRule = URBNDateRule(comparisonType: comparisonType, localizationKey: localizationKey)
    }
}
