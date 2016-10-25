//
//  URBNLengthRules.swift
//  URBNValidator
//
//  Created by Joseph Ridenour on 11/25/15.
//
//

import Foundation


public protocol Lengthable {
    var length: Int { get }
}

extension String: Lengthable {
    public var length: Int {
        return self.characters.count
    }
}
extension NSString: Lengthable {}
extension Array: Lengthable {
    public var length: Int {
        return self.count
    }
}

extension NSArray: Lengthable {
    public var length: Int {
        return self.count
    }
}

extension Dictionary: Lengthable {
    public var length: Int {
        return self.count
    }
}

extension NSDictionary: Lengthable {
    public var length: Int {
        return self.count
    }
}

extension TimeInterval: Lengthable {
    public var length: Int {
        return Int(self)
    }
}

extension NSNumber: Lengthable {
    public var length: Int {
        return self.intValue;
    }
}

func validate<T>(_ value: T?, limit: Int, comparisonFunc: (_ lhs: Int, _ rhs: Int) -> Bool) -> Bool {
    guard let lengthableVal = value as? Lengthable else { return false }
    return comparisonFunc(lengthableVal.length, limit)
}

open class BaseLengthRule: URBNBaseRule, URBNRequirement {
    open var limit: Int = 0
    open var isRequired: Bool = false
    open var isInclusive: Bool = false
    
    public init(limit: Int, inclusive: Bool = false, localizationKey: String? = nil) {
        self.limit = limit
        self.isInclusive = inclusive
        super.init(localizationKey: localizationKey)
    }
    
    open override func validateValue<T>(_ value: T?) -> Bool {
        if !isRequired && value == nil { return true }
        
        return validate(value, limit: limit, comparisonFunc: comparisonFunc)
    }
    
    var comparisonFunc: (_ lhs: Int, _ rhs: Int) -> Bool { return { _,_ in false } }
}

open class URBNMinLengthRule: BaseLengthRule {
    public init(minLength: Int, inclusive: Bool = false, localizationKey: String? = nil) {
        super.init(limit: minLength, inclusive: inclusive, localizationKey: localizationKey)
    }
    
    override var comparisonFunc: (_ lhs: Int, _ rhs: Int) -> Bool { return isInclusive ? (>=) : (>) }
}

open class URBNMaxLengthRule: BaseLengthRule {
    public init(maxLength: Int, inclusive: Bool = false, localizationKey: String? = nil) {
        super.init(limit: maxLength, inclusive: inclusive, localizationKey: localizationKey)
    }
    
    override var comparisonFunc: (_ lhs: Int, _ rhs: Int) -> Bool { return isInclusive ? (<=) : (<) }
}
