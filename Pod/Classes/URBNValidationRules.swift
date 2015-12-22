//
//  ValidatorRules.swift
//  URBNValidator
//
//  Created by Joseph Ridenour on 11/23/15.
//
//

import Foundation


public protocol ValidationRule {
    var localizationKey: String { get set }
    func validateValue(value: Any?) -> Bool
    func validateValue(value: Any?, key: String) -> Bool
}

public protocol URBNRequirement {
    var isRequired: Bool { get set }
}


public class URBNBaseRule: ValidationRule {
    var _localizationKey: String?
    public var localizationKey: String  {
        get {
            if (_localizationKey == nil) {
                return NSStringFromClass(self.dynamicType)
            }
            return _localizationKey!
        }
        set {
            _localizationKey = newValue
        }
    }
    
    public init(localizationKey: String? = nil) {
        if localizationKey != nil && localizationKey?.length > 0 {
            self.localizationKey = localizationKey!
        }
    }
    
    public func validateValue(value: Any?) -> Bool {
        return true
    }
    
    public func validateValue(value: Any?, key: String) -> Bool {
        self.localizationKey = key
        return self.validateValue(value)
    }
}

public class URBNRequiredRule: URBNBaseRule {
    public override init(localizationKey: String? = nil) {
        super.init(localizationKey: localizationKey)
    }
    public override func validateValue(value: Any?) -> Bool {
        if value is String {
            /// Also validate the value is not empty here.  
            /// We're only doing this for backwards compatibility with QBValidator.
            /// We should decide if this is the way to go about this.
            return (value as! String).length > 0
        }
        return value != nil
    }
}

public class URBNNotRequiredRule: URBNBaseRule {
    public override init(localizationKey: String? = nil) {
        super.init(localizationKey: localizationKey)
    }
    public override func validateValue(value: Any?) -> Bool {
        return true
    }
}
public typealias BlockValidation = (value: Any?) -> Bool
public class URBNBlockRule: URBNBaseRule {
    public var blockValidation: BlockValidation
    
    public init(_ validator: BlockValidation) {
        blockValidation = validator
        super.init()
    }
    
    public init(validator: BlockValidation, localizationKey: String? = nil) {
        blockValidation = validator
        super.init(localizationKey: localizationKey)
    }
    
    public override func validateValue(value: Any?) -> Bool {
        return self.blockValidation(value: value)
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

public class URBNRegexRule: URBNBaseRule, URBNRequirement {
    internal var pattern: String
    public var isRequired: Bool = false
    
    public init(pattern: String, localizationKey: String? = nil) {
        self.pattern = pattern
        super.init(localizationKey: localizationKey)
    }
    
    public override func validateValue(value: Any?) -> Bool {
        if !isRequired && value == nil { return true }
        
        let pred = NSPredicate(format: "SELF MATCHES[cd] %@", self.pattern)
        return pred.evaluateWithObject(value as! AnyObject?)
    }
}

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
    
    public static let emailPattern = "^(?:(?:(?:(?:[a-zA-Z0-9_!#\\$\\%&'*+/=?\\^`{}~|\\-]+)(?:\\.(?:[a-zA-Z0-9_!#\\$\\%&'*+/=?\\^`{}~|\\-]+))*)|(?:\"(?:\\\\[^\\r\\n]|[^\\\\\"])*\")))\\@(?:(?:(?:(?:[a-zA-Z0-9_!#\\$\\%&'*+/=?\\^`{}~|\\-]+)(?:\\.(?:[a-zA-Z0-9_!#\\$%&'*+/=?\\^`{}~|\\-]+))*)|(?:\\[(?:\\\\\\S|[\\x21-\\x5a\\x5e-\\x7e])*\\])))$"
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