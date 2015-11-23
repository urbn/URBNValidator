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


