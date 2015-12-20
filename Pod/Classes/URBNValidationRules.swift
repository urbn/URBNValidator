//
//  ValidatorRules.swift
//  URBNValidator
//
//  Created by Joseph Ridenour on 11/23/15.
//
//

import Foundation


public protocol ValidationRule {
    typealias VR
    var localizationKey: String { get set }
    func validateValue(value: VR?) -> Bool
    func validateValue(value: VR?, key: String) -> Bool
}

public protocol URBNRequirement {
    var isRequired: Bool { get set }
}


public class URBNBaseRule<T>: ValidationRule {
    public typealias VR = T
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
    
    public func validateValue(value: T?) -> Bool {
        return true
    }
    
    public func validateValue(value: T?, key: String) -> Bool {
        self.localizationKey = key
        return self.validateValue(value)
    }
}

public class URBNRequiredRule<T>: URBNBaseRule<T> {
    public override init(localizationKey: String? = nil) {
        super.init(localizationKey: localizationKey)
    }
    public override func validateValue(value: T?) -> Bool {
        if value is String {
            /// Also validate the value is not empty here.  
            /// We're only doing this for backwards compatibility with QBValidator.
            /// We should decide if this is the way to go about this.
            return (value as! String).length > 0
        }
        return value != nil
    }
}

public class URBNNotRequiredRule<T>: URBNBaseRule<T> {
    public override init(localizationKey: String? = nil) {
        super.init(localizationKey: localizationKey)
    }
    public override func validateValue(value: T?) -> Bool {
        return true
    }
}

public class URBNBlockRule<T>: URBNBaseRule<T> {
    public typealias BlockValidation = (value: T?) -> Bool
    public var blockValidation: BlockValidation
    
    public init(_ validator: BlockValidation) {
        blockValidation = validator
        super.init()
    }
    
    public init(validator: BlockValidation, localizationKey: String? = nil) {
        blockValidation = validator
        super.init(localizationKey: localizationKey)
    }
    
    public override func validateValue(value: T?) -> Bool {
        return self.blockValidation(value: value)
    }
}

@objc public class CompatBlockRule: CompatBaseRule {
    public typealias BlockValidation = (value: AnyObject?) -> Bool

    public init(_ validator: BlockValidation) {
        super.init()
        let blockRule = URBNBlockRule<AnyObject>(validator)
        blockRule.blockValidation = validator
        self.baseRule = blockRule
    }
    public init(validator: BlockValidation, localizationKey: String? = nil) {
        super.init(localizationKey: localizationKey)
        let blockRule = URBNBlockRule<AnyObject>(validator: validator, localizationKey: localizationKey)
        blockRule.blockValidation = validator
        self.baseRule = blockRule
    }
}

public class URBNRegexRule<T: AnyObject>: URBNBaseRule<T>, URBNRequirement {
    internal var pattern: String
    public var isRequired: Bool = false
    
    public init(pattern: String, localizationKey: String? = nil) {
        self.pattern = pattern
        super.init(localizationKey: localizationKey)
    }
    
    public override func validateValue(value: T?) -> Bool {
        if !isRequired && value == nil { return true }
        
        let pred = NSPredicate(format: "SELF MATCHES[cd] %@", self.pattern)
        return pred.evaluateWithObject(value)
    }
}

@objc public protocol OCValidationRule {
    var localizationKey: String { get set }
    func validateValue(value: AnyObject?) -> Bool
    func validateValue(value: AnyObject?, key: String) -> Bool
}

@objc public class CompatBaseRule: NSObject, OCValidationRule {
    var baseRule: URBNBaseRule<AnyObject>
    
    public init(localizationKey: String? = nil) {
        baseRule = URBNBaseRule<AnyObject>(localizationKey: localizationKey)
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
            if let requiredBaseRule = self.baseRule as? URBNRegexRule<AnyObject> {
                return requiredBaseRule.isRequired
            }
        
            return false
        }
        set {
            if let requiredBaseRule = self.baseRule as? URBNRegexRule<AnyObject> {
                requiredBaseRule.isRequired = newValue
            }
        }
    }
    
    public init(pattern: String, localizationKey: String? = nil) {
        super.init()
        self.baseRule = URBNRegexRule<AnyObject>(pattern: pattern, localizationKey: localizationKey)
    }
    
    public static let emailPattern = "^(?:(?:(?:(?:[a-zA-Z0-9_!#\\$\\%&'*+/=?\\^`{}~|\\-]+)(?:\\.(?:[a-zA-Z0-9_!#\\$\\%&'*+/=?\\^`{}~|\\-]+))*)|(?:\"(?:\\\\[^\\r\\n]|[^\\\\\"])*\")))\\@(?:(?:(?:(?:[a-zA-Z0-9_!#\\$\\%&'*+/=?\\^`{}~|\\-]+)(?:\\.(?:[a-zA-Z0-9_!#\\$%&'*+/=?\\^`{}~|\\-]+))*)|(?:\\[(?:\\\\\\S|[\\x21-\\x5a\\x5e-\\x7e])*\\])))$"
}

@objc public class CompatRequiredRule: CompatBaseRule {
    public override init(localizationKey: String? = nil) {
        super.init(localizationKey: localizationKey)
        self.baseRule = URBNRequiredRule<AnyObject>()
    }
}

@objc public class CompatNotRequiredRule: CompatBaseRule {
    public override init(localizationKey: String? = nil) {
        super.init(localizationKey: localizationKey)
        self.baseRule = URBNNotRequiredRule<AnyObject>()
    }
}