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
    public init() {}
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
    public init() {}

    public override func validateValue(value: T?) -> Bool {
        return true
    }
}

//public class URBNBlockRule: URBNBaseRule {
//    public typealias BlockValidation = (value: AnyObject?) -> Bool
//    public var blockValidation: BlockValidation
//    
//    public init(_ validator: BlockValidation) {
//        blockValidation = validator
//        super.init()
//    }
//    
//    public init(validator: BlockValidation, localizationKey: String? = nil) {
//        blockValidation = validator
//        super.init(localizationKey: localizationKey)
//    }
//    
//    public override func validateValue<T>(value: T?) -> Bool {
//        return self.blockValidation(value: value)
//    }
//}

public class URBNRegexRule<T>: URBNBaseRule<T>, URBNRequirement {
    internal var pattern: String
    public var isRequired: Bool = false
    
    public init(pattern: String, localizationKey: String? = nil) {
        self.pattern = pattern
        super.init(localizationKey: localizationKey)
    }
    
    public override func validateValue(value: T?) -> Bool {
        if !isRequired && value == nil { return true }
        
        let pred = NSPredicate(format: "SELF MATCHES[cd] %@", self.pattern)
        return false//pred.evaluateWithObject(value)
    }
    
    //public static let emailPattern = "^(?:(?:(?:(?:[a-zA-Z0-9_!#\\$\\%&'*+/=?\\^`{}~|\\-]+)(?:\\.(?:[a-zA-Z0-9_!#\\$\\%&'*+/=?\\^`{}~|\\-]+))*)|(?:\"(?:\\\\[^\\r\\n]|[^\\\\\"])*\")))\\@(?:(?:(?:(?:[a-zA-Z0-9_!#\\$\\%&'*+/=?\\^`{}~|\\-]+)(?:\\.(?:[a-zA-Z0-9_!#\\$%&'*+/=?\\^`{}~|\\-]+))*)|(?:\\[(?:\\\\\\S|[\\x21-\\x5a\\x5e-\\x7e])*\\])))$"
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
