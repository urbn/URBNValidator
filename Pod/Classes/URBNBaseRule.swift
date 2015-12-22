//
//  URBNBaseRule.swift
//  URBNValidator
//
//  Created by Joseph Ridenour on 12/22/15.
//
//

import Foundation


public protocol ValidationRule {
    var localizationKey: String { get set }
    func validateValue<T>(value: T?) -> Bool
    func validateValue<T>(value: T?, key: String) -> Bool
}

public protocol URBNRequirement {
    var isRequired: Bool { get set }
}

public class URBNBaseRule: ValidationRule {
    var _localizationKey: String?
    public var localizationKey: String  {
        get {
            if let key = _localizationKey {
                return key
            }
            else {
                return NSStringFromClass(self.dynamicType)
            }
        }
        set {
            _localizationKey = newValue
        }
    }
    
    public init(localizationKey: String? = nil) {
        if let key = localizationKey where localizationKey?.length > 0 {
            self.localizationKey = key
        }
    }
    
    public func validateValue<T>(value: T?) -> Bool {
        return true
    }
    
    public func validateValue<T>(value: T?, key: String) -> Bool {
        self.localizationKey = key
        return self.validateValue(value)
    }
}
