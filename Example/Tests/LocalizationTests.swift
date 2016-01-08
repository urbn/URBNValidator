//
//  LocalizationTests.swift
//  URBNValidator
//
//  Created by Joseph Ridenour on 1/5/16.
//  Copyright © 2016 URBN. All rights reserved.
//

import Foundation
import XCTest
@testable import URBNValidator

class LocalizationTests: XCTestCase {
    
    
    func testDefaultLocalizationKeys() {
        XCTAssertEqual(URBNRequiredRule().localizationKey, "ls_URBNValidator_URBNValidator.URBNRequiredRule")
        XCTAssertEqual(URBNMinLengthRule(minLength: 0).localizationKey, "ls_URBNValidator_URBNValidator.URBNMinLengthRule")
        XCTAssertEqual(URBNMaxLengthRule(maxLength: 0).localizationKey, "ls_URBNValidator_URBNValidator.URBNMaxLengthRule")
        XCTAssertEqual(URBNRegexRule(pattern: "").localizationKey, "ls_URBNValidator_URBNValidator.URBNRegexRule")
        XCTAssertEqual(URBNRegexRule(patternType: .AlphaNumeric).localizationKey, "ls_URBNValidator_URBNValidator.URBNRegexRule")
        XCTAssertEqual(URBNRegexRule(patternType: .Email).localizationKey, "ls_URBNValidator_URBNValidator.URBNRegexEmailRule")
        XCTAssertEqual(URBNRegexRule(patternType: .Letters).localizationKey, "ls_URBNValidator_URBNValidator.URBNRegexLettersRule")
        XCTAssertEqual(URBNRegexRule(patternType: .Numbers).localizationKey, "ls_URBNValidator_URBNValidator.URBNRegexNumbersRule")
        XCTAssertEqual(URBNDateRule().localizationKey, "ls_URBNValidator_URBNValidator.URBNDatePastRule")
        XCTAssertEqual(URBNDateRule(comparisonType: .Future).localizationKey, "ls_URBNValidator_URBNValidator.URBNDateFutureRule")
        XCTAssertEqual(URBNBlockRule(validator: { _ in true }).localizationKey, "ls_URBNValidator_URBNValidator.URBNBlockRule")
    }
    
    func testDefaultLocalizationStrings() {
        let vd = URBNValidator()
        
        let localizedError: (ValidationRule) -> String? = { (rule) -> String? in
            return vd.localizeableString(rule, key: "test", value: "value")
        }
        
        
        XCTAssertEqual(localizedError(URBNRequiredRule()), "test is required.")
        XCTAssertEqual(localizedError(URBNMinLengthRule(minLength: 0)), "too short")
        XCTAssertEqual(localizedError(URBNMaxLengthRule(maxLength: 0)), "too long")
        XCTAssertEqual(localizedError(URBNRegexRule(pattern: "")), "Invalid characters")
        XCTAssertEqual(localizedError(URBNRegexRule(patternType: .Email)), "Email is not valid")
        XCTAssertEqual(localizedError(URBNRegexRule(patternType: .Numbers)), "Numbers only")
        XCTAssertEqual(localizedError(URBNRegexRule(patternType: .Letters)), "Letters only")
        XCTAssertEqual(localizedError(URBNRegexRule(patternType: .AlphaNumeric)), "Invalid characters")
        XCTAssertEqual(localizedError(URBNDateRule()), "Date must be in the past")
        XCTAssertEqual(localizedError(URBNDateRule(comparisonType: .Future)), "Date must be in the future")
    }
    
    
    func testLocalizationOverrideKeys() {
        XCTAssertEqual(URBNRequiredRule(localizationKey: "Required").localizationKey, "Required")
        XCTAssertEqual(URBNMinLengthRule(minLength: 0, inclusive: true, localizationKey: "MinLength").localizationKey, "MinLength")
        XCTAssertEqual(URBNMaxLengthRule(maxLength: 0, inclusive: true, localizationKey: "MaxLength").localizationKey, "MaxLength")
        XCTAssertEqual(URBNRegexRule(pattern: "", localizationKey: "Regex").localizationKey, "Regex")
        XCTAssertEqual(URBNDateRule(comparisonType: .Past, localizationKey: "DateIsPast").localizationKey, "DateIsPast")
        XCTAssertEqual(URBNDateRule(comparisonType: .Future, localizationKey: "DateIsFuture").localizationKey, "DateIsFuture")
        XCTAssertEqual(URBNBlockRule(validator: { _ in true }, localizationKey: "CustomBlockFailed").localizationKey, "CustomBlockFailed")
    }
    
    
    func testLocalizationOverrideStrings() {
        let vd = URBNValidator()
        
        let localizedError: (ValidationRule) -> String? = { (rule) -> String? in
            return vd.localizeableString(rule, key: "test", value: "value")
        }
        
        
        XCTAssertEqual(localizedError(URBNRequiredRule(localizationKey: "Required")), "Required")
        XCTAssertEqual(localizedError(URBNMinLengthRule(minLength: 0, inclusive: true, localizationKey: "MinLength")), "MinLength")
        XCTAssertEqual(localizedError(URBNMaxLengthRule(maxLength: 0, inclusive: true, localizationKey: "MaxLength")), "MaxLength")
        XCTAssertEqual(localizedError(URBNRegexRule(pattern: "", localizationKey: "Regex")), "Regex")
        XCTAssertEqual(localizedError(URBNDateRule(comparisonType: .Past, localizationKey: "DateIsPast")), "DateIsPast")
        XCTAssertEqual(localizedError(URBNDateRule(comparisonType: .Future, localizationKey: "DateIsFuture")), "DateIsFuture")
        XCTAssertEqual(localizedError(URBNBlockRule(validator: { _ in true }, localizationKey: "CustomBlockFailed")), "CustomBlockFailed")
    }
}