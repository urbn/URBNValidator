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
let lettersPattern = "^[A-Z"
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
        default: return ""
        }
    }
    
    var localizeString: String? {
        switch(self) {
        case .Email: return "URBNValidator.URBNRegexEmailRule"
        case .Letters: return "URBNValidator.URBNRegexLettersRule"
        case .Numbers: return "URBNValidator.URBNRegexNumbersRule"
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
    
    public override func validateValue<T>(value: T?) -> Bool {
        if !isRequired && value == nil { return true }
        
        let pred = NSPredicate(format: "SELF MATCHES[cd] %@", self.pattern)
        
        return pred.evaluateWithObject(value as? AnyObject)
    }
}

extension URBNRegexRule {
    convenience init(patternType: URBNRegexPattern, localizationKey: String? = nil) {
        self.init(pattern: patternType.patternString, localizationKey: localizationKey ?? patternType.localizeString)
    }
}