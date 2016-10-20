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
    func validateValue<T>(_ value: T?) -> Bool
    func validateValue<T>(_ value: T?, key: String) -> Bool
}

public protocol URBNRequirement {
    var isRequired: Bool { get set }
}

open class URBNBaseRule: ValidationRule {
    var _localizationKey: String?
    open var localizationKey: String  {
        get {
            if let key = _localizationKey {
                return key
            }
            else {
                return "\(type(of: self))"
            }
        }
        set {
            _localizationKey = newValue
        }
    }
    
    public init(localizationKey: String? = nil) {
        if let key = localizationKey , !key.isEmpty {
            self.localizationKey = key
        }
    }
    
    open func validateValue<T>(_ value: T?) -> Bool {
        return true
    }
    
    open func validateValue<T>(_ value: T?, key: String) -> Bool {
        self.localizationKey = key
        return self.validateValue(value)
    }
}
