//
//  ValidatorRules.swift
//  URBNValidator
//
//  Created by Joseph Ridenour on 11/23/15.
//
//

import Foundation


public protocol ValidationRule {
    typealias T
    var localizationKey: String { get set }
    func validateValue(value: T?) -> Bool
    func validateValue(value: T?, key: String) -> Bool
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
    
    public func validateValue(value: AnyObject?) -> Bool {
        return true
    }
    
    public func validateValue(value: AnyObject?, key: String) -> Bool {
        self.localizationKey = key
        return self.validateValue(value)
    }
}

public class URBNRequiredRule: URBNBaseRule {
    
    public override func validateValue(value: AnyObject?) -> Bool {
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
    public override func validateValue(value: AnyObject?) -> Bool {
        return true
    }
}

public class URBNBlockRule: URBNBaseRule {
    public typealias BlockValidation = (value: AnyObject?) -> Bool
    public var blockValidation: BlockValidation
    
    public init(_ validator: BlockValidation) {
        blockValidation = validator
        super.init()
    }
    
    public init(validator: BlockValidation, localizationKey: String? = nil) {
        blockValidation = validator
        super.init(localizationKey: localizationKey)
    }
    
    public override func validateValue(value: AnyObject?) -> Bool {
        return self.blockValidation(value: value)
    }
}

public class URBNRegexRule: URBNBaseRule, URBNRequirement {
    internal var pattern: String
    public var isRequired: Bool = false
    
    public init(pattern: String, localizationKey: String? = nil) {
        self.pattern = pattern
        super.init(localizationKey: localizationKey)
    }
    
    public override func validateValue(value: AnyObject?) -> Bool {
        if !isRequired && value == nil { return true }
        
        let pred = NSPredicate(format: "SELF MATCHES[cd] %@", self.pattern)
        return pred.evaluateWithObject(value)
    }
    
    public static let emailPattern = "^(?:(?:(?:(?:[a-zA-Z0-9_!#\\$\\%&'*+/=?\\^`{}~|\\-]+)(?:\\.(?:[a-zA-Z0-9_!#\\$\\%&'*+/=?\\^`{}~|\\-]+))*)|(?:\"(?:\\\\[^\\r\\n]|[^\\\\\"])*\")))\\@(?:(?:(?:(?:[a-zA-Z0-9_!#\\$\\%&'*+/=?\\^`{}~|\\-]+)(?:\\.(?:[a-zA-Z0-9_!#\\$%&'*+/=?\\^`{}~|\\-]+))*)|(?:\\[(?:\\\\\\S|[\\x21-\\x5a\\x5e-\\x7e])*\\])))$"
}
