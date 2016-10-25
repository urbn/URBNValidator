
//
//  URBNValidationRulesCompat.swift
//  URBNValidator
//
//  Created by Nick DiStefano on 12/21/15.
//
//

import Foundation


@objc open class URBNCompatBaseRule: NSObject {
    var backingRule: URBNBaseRule
    
    public init(localizationKey: String? = nil) {
        backingRule = URBNBaseRule(localizationKey: localizationKey)
        super.init()
    }
    
    open func validateValue(_ value: Any?) -> Bool { return backingRule.validateValue(value) }
    
    open func validateValue(_ value: Any?, key: String) -> Bool { return backingRule.validateValue(value, key: key) }
    
    open var localizationKey: String  {
        get {
            return backingRule.localizationKey
        }
        set {
            backingRule.localizationKey = newValue
        }
    }
}

@objc open class URBNCompatRequirementRule: URBNCompatBaseRule, URBNRequirement {
    open var isRequired: Bool {
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

@objc open class URBNCompatRegexRule: URBNCompatRequirementRule {
    public init(pattern: String, localizationKey: String? = nil) {
        super.init()
        backingRule = URBNRegexRule(pattern: pattern, localizationKey: localizationKey)
    }
    
    public convenience init(patternType: URBNRegexPattern, localizationKey: String? = nil) {
        self.init(pattern: patternType.patternString, localizationKey: localizationKey)
    }
}

@objc open class URBNCompatRequiredRule: URBNCompatBaseRule {
    public override init(localizationKey: String? = nil) {
        super.init(localizationKey: localizationKey)
        backingRule = URBNRequiredRule()
    }
}

@objc open class URBNCompatNotRequiredRule: URBNCompatBaseRule {
    public override init(localizationKey: String? = nil) {
        super.init(localizationKey: localizationKey)
        backingRule = URBNNotRequiredRule()
    }
}

@objc open class URBNCompatBlockRule: URBNCompatBaseRule {
    public typealias CompatBlockValidation = (_ value: AnyObject?) -> Bool
    
    public init(_ validator: @escaping BlockValidation) {
        super.init()
        let blockRule = URBNBlockRule(validator)
        blockRule.blockValidation = validator
        backingRule = blockRule
    }
    
    public init(validator: @escaping BlockValidation, localizationKey: String? = nil) {
        super.init(localizationKey: localizationKey)
        let blockRule = URBNBlockRule(validator: validator, localizationKey: localizationKey)
        blockRule.blockValidation = validator
        backingRule = blockRule
    }
    
    public convenience init(_ validator: @escaping CompatBlockValidation, localizationKey: String?) {
        let compatWrappingBlock = { (anyValue: Any?) -> Bool in
            if let anyObjectValue = anyValue as? AnyObject {
                return validator(anyObjectValue)
            }
            
            return false
        }
        
        self.init(validator: compatWrappingBlock, localizationKey: localizationKey)
    }
}

@objc open class URBNCompatDateRule: URBNCompatBaseRule {
    
    public init(comparisonType: URBNDateComparision = .past, localizationKey: String? = nil, comparisonUnit: NSCalendar.Unit) {
        super.init()
        let r = URBNDateRule(comparisonType: comparisonType, localizationKey: localizationKey)
        r.comparisonUnit = comparisonUnit
        backingRule = r
    }
    
    /// Here we're making sure that we're given an NSDate because objc is 
    /// dumb and will allow the user to not give an NSDate
    open override func validateValue(_ value: Any?) -> Bool {
        guard let value = value as? Date else { return false }
        return super.validateValue(value)
    }
    
    open override func validateValue(_ value: Any?, key: String) -> Bool {
        guard let value = value as? Date else { return false }
        return super.validateValue(value, key: key)
    }
}
