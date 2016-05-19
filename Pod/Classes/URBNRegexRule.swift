//
//  URBNRegexRule.swift
//  URBNValidator
//
//  Created by Joseph Ridenour on 12/22/15.
//
//

import Foundation


let emailPattern = "^(?:(?:(?:(?:[a-zA-Z0-9_!#\\$\\%&'*+/=?\\^`{}~|\\-]+)(?:\\.(?:[a-zA-Z0-9_!#\\$\\%&'*+/=?\\^`{}~|\\-]+))*)|(?:\"(?:\\\\[^\\r\\n]|[^\\\\\"])*\")))\\@(?:(?:(?:(?:[a-zA-Z0-9_!#\\$\\%&'*+/=?\\^`{}~|\\-]+)(?:\\.(?:[a-zA-Z0-9_!#\\$%&'*+/=?\\^`{}~|\\-]+))*)|(?:\\[(?:\\\\\\S|[\\x21-\\x5a\\x5e-\\x7e])*\\])))$"
let alphaNumericPattern = "^[A-Z\\d]"
let lettersPattern = "^[A-Z]"
let numericPattern = "^[\\d]"

@objc public enum URBNRegexPattern: Int {
    case AlphaNumeric
    case Email
    case Letters
    case Numbers
    
    var patternString: String {
        switch(self) {
        case .Email: return emailPattern
        case .AlphaNumeric: return alphaNumericPattern
        case .Numbers: return numericPattern
        case .Letters: return lettersPattern
        }
    }
    
    var localizeString: String? {
        switch(self) {
        case .Email: return "URBNRegexEmailRule"
        case .Letters: return "URBNRegexLettersRule"
        case .Numbers: return "URBNRegexNumbersRule"
        default: return nil
        }
    }
}

public class URBNRegexRule: URBNBaseRule, URBNRequirement {
    internal var pattern: String
    public var isRequired: Bool = false
    
    public init(pattern: String, localizationKey: String? = nil) {
        self.pattern = pattern
        super.init(localizationKey: localizationKey)
    }
    
    public override func validateValue<T: AnyObject>(value: T?) -> Bool {
        if !isRequired && value == nil { return true }
        
        guard let v = value as? AnyObject else {
            print("WARNING:  Passing \(value) to expected type of AnyObject in URBNRegexRule.  This is technically not allowed, but because objc let's it slide we have to support it.   You're probably doing something wrong.")
            return false
        }
        
        let pred = NSPredicate(format: "SELF MATCHES[cd] %@", self.pattern)
        
        return pred.evaluateWithObject(v)
    }
}

extension URBNRegexRule {
    public convenience init(patternType: URBNRegexPattern, localizationKey: String? = nil) {
        self.init(pattern: patternType.patternString, localizationKey: localizationKey ?? patternType.localizeString)
    }
}