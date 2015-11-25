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

public class URBNMinLengthRule: URBNBaseRule {
    public var minLength: Int = 0
    
    public init(minLength: Int) {
        self.minLength = minLength
        super.init()
    }
    
    public override func validateValue(value: AnyObject?) -> Bool {
        
        if value is Lengthable {
            return (value as! Lengthable).length >= minLength
        }
        
        return false
    }
}

public class URBNMaxLengthRule: URBNBaseRule {
    public var maxLength: Int = 10
    
    public init(maxLength: Int) {
        self.maxLength = maxLength
        super.init()
    }
    
    public override func validateValue(value: AnyObject?) -> Bool {
        if value is Lengthable {
            return (value as! Lengthable).length <= maxLength
        }
        
        return false
    }
}
