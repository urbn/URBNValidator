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
        get { return self.characters.count }
    }
}
extension NSString: Lengthable {}
extension Array: Lengthable {
    var length: Int {
        get { return self.count }
    }
}

extension NSArray: Lengthable {
    var length: Int {
        get { return self.count }
    }
}

extension Dictionary: Lengthable {
    var length: Int {
        get { return self.count }
    }
}

extension NSDictionary: Lengthable {
    var length: Int {
        get { return self.count }
    }
}

public class URBNMinLengthRule: URBNBaseRule, URBNRequirement {
    public var minLength: Int = 0
    public var isRequired: Bool = false
    
    public init(minLength: Int) {
        self.minLength = minLength
        super.init()
    }
    
    public override func validateValue(value: AnyObject?) -> Bool {
        if !isRequired && value == nil { return true }
        
        if value is Lengthable {
            return (value as! Lengthable).length >= minLength
        }
        
        return false
    }
}

public class URBNMaxLengthRule: URBNBaseRule, URBNRequirement {
    public var maxLength: Int = 10
    public var isRequired: Bool = false
    
    public init(maxLength: Int) {
        self.maxLength = maxLength
        super.init()
    }
    
    public override func validateValue(value: AnyObject?) -> Bool {
        if !isRequired && value == nil { return true }
        
        if value is Lengthable {
            return (value as! Lengthable).length <= maxLength
        }
        
        return false
    }
}
