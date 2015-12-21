//
//  URBNLengthRules.swift
//  URBNValidator
//
//  Created by Joseph Ridenour on 11/25/15.
//
//

import Foundation


protocol Lengthable {
    var length: Int { get }
}

extension String: Lengthable {
    var length: Int {
        return self.characters.count
    }
}
extension NSString: Lengthable {}
extension Array: Lengthable {
    var length: Int {
        return self.count
    }
}

extension NSArray: Lengthable {
    var length: Int {
        return self.count
    }
}

extension Dictionary: Lengthable {
    var length: Int {
        return self.count
    }
}

extension NSDictionary: Lengthable {
    var length: Int {
        return self.count
    }
}

extension NSTimeInterval: Lengthable {
    var length: Int {
        return Int(self)
    }
}

extension NSNumber: Lengthable {
    var length: Int {
        return self.integerValue;
    }
}

func validate<T>(value: T?, limit: Int, comparisonFunc: (lhs: Int, rhs: Int) -> Bool) -> Bool {
    guard let lengthableVal = value as? Lengthable else { return false }
    return comparisonFunc(lhs: lengthableVal.length, rhs: limit)
}

public class BaseLengthRule: URBNBaseRule, URBNRequirement {
    public var limit: Int = 0
    public var isRequired: Bool = false
    public var isInclusive: Bool = false
    
    public init(limit: Int, inclusive: Bool = false, localizationKey: String? = nil) {
        self.limit = limit
        self.isInclusive = inclusive
        super.init(localizationKey: localizationKey)
    }
    
    public override func validateValue(value: Any?) -> Bool {
        if !isRequired && value == nil { return true }
        
        return validate(value, limit: limit, comparisonFunc: comparisonFunc)
    }
    
    var comparisonFunc: (lhs: Int, rhs: Int) -> Bool { return { _,_ in false } }
}

public class URBNMinLengthRule: BaseLengthRule {
    public init(minLength: Int, inclusive: Bool = false, localizationKey: String? = nil) {
        super.init(limit: minLength, inclusive: inclusive, localizationKey: localizationKey)
    }
    
    override var comparisonFunc: (lhs: Int, rhs: Int) -> Bool { return isInclusive ? (>=) : (>) }
}

public class URBNMaxLengthRule: BaseLengthRule {
    public init(maxLength: Int, inclusive: Bool = false, localizationKey: String? = nil) {
        super.init(limit: maxLength, inclusive: inclusive, localizationKey: localizationKey)
    }
    
    override var comparisonFunc: (lhs: Int, rhs: Int) -> Bool { return isInclusive ? (<=) : (<) }
}

@objc public class CompatMinLR: CompatBaseRule {
    public init(minLength: Int, inclusive: Bool = false, localizationKey: String? = nil) {
        super.init()
        self.baseRule = URBNMinLengthRule(minLength: minLength, inclusive: inclusive, localizationKey: localizationKey)
    }
}

@objc public class CompatMaxLR: CompatBaseRule {
    public init(maxLength: Int, inclusive: Bool = false, localizationKey: String? = nil) {
        super.init()
        self.baseRule = URBNMaxLengthRule(maxLength: maxLength, inclusive: inclusive, localizationKey: localizationKey)
    }
}