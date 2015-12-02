//
//  ValidatorRules.swift
//  URBNValidator
//
//  Created by Joseph Ridenour on 11/23/15.
//
//

import Foundation


@objc public protocol ValidationRule {
    var localizationKey: String { get set }
    func validateValue(value: AnyObject?) -> Bool
    func validateValue(value: AnyObject?, key: String) -> Bool
}

public class URBNBaseRule: NSObject, ValidationRule {
    public var localizationKey = "URBNBaseRule"
    
    public override init() {
        super.init()
        self.localizationKey = "\(self.classForCoder)"
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
        return value != nil
    }
}

public class URBNBlockRule: URBNBaseRule {
    public typealias BlockValidation = (value: AnyObject?) -> Bool
    public var blockValidation: BlockValidation
    
    public init(validator: BlockValidation) {
        blockValidation = validator
        super.init()
    }
    
    public override func validateValue(value: AnyObject?) -> Bool {
        return self.blockValidation(value: value)
    }
}

public class URBNRegexRule: URBNBaseRule {
    internal var pattern: String
    
    public init(pattern: String) {
        self.pattern = pattern
        super.init()
    }
    
    public override func validateValue(value: AnyObject?) -> Bool {
        let pred = NSPredicate(format: "SELF MATCHES[cd] %@", self.pattern)
        return pred.evaluateWithObject(value)
    }
}
