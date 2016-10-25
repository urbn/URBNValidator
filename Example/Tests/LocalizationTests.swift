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
        XCTAssertEqual(URBNRequiredRule().localizationKey, "URBNRequiredRule")
        XCTAssertEqual(URBNMinLengthRule(minLength: 0).localizationKey, "URBNMinLengthRule")
        XCTAssertEqual(URBNMaxLengthRule(maxLength: 0).localizationKey, "URBNMaxLengthRule")
        XCTAssertEqual(URBNRegexRule(pattern: "").localizationKey, "URBNRegexRule")
        XCTAssertEqual(URBNRegexRule(patternType: .alphaNumeric).localizationKey, "URBNRegexRule")
        XCTAssertEqual(URBNRegexRule(patternType: .email).localizationKey, "URBNRegexEmailRule")
        XCTAssertEqual(URBNRegexRule(patternType: .letters).localizationKey, "URBNRegexLettersRule")
        XCTAssertEqual(URBNRegexRule(patternType: .numbers).localizationKey, "URBNRegexNumbersRule")
        XCTAssertEqual(URBNDateRule().localizationKey, "URBNDatePastRule")
        XCTAssertEqual(URBNDateRule(comparisonType: .future).localizationKey, "URBNDateFutureRule")
        XCTAssertEqual(URBNBlockRule(validator: { _ in true }).localizationKey, "URBNBlockRule")
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
        XCTAssertEqual(localizedError(URBNRegexRule(patternType: .email)), "Email is not valid")
        XCTAssertEqual(localizedError(URBNRegexRule(patternType: .numbers)), "Numbers only")
        XCTAssertEqual(localizedError(URBNRegexRule(patternType: .letters)), "Letters only")
        XCTAssertEqual(localizedError(URBNRegexRule(patternType: .alphaNumeric)), "Invalid characters")
        XCTAssertEqual(localizedError(URBNDateRule()), "Date must be in the past")
        XCTAssertEqual(localizedError(URBNDateRule(comparisonType: .future)), "Date must be in the future")
    }
    
    
    func testLocalizationOverrideKeys() {
        XCTAssertEqual(URBNRequiredRule(localizationKey: "Required").localizationKey, "Required")
        XCTAssertEqual(URBNMinLengthRule(minLength: 0, inclusive: true, localizationKey: "MinLength").localizationKey, "MinLength")
        XCTAssertEqual(URBNMaxLengthRule(maxLength: 0, inclusive: true, localizationKey: "MaxLength").localizationKey, "MaxLength")
        XCTAssertEqual(URBNRegexRule(pattern: "", localizationKey: "Regex").localizationKey, "Regex")
        XCTAssertEqual(URBNDateRule(comparisonType: .past, localizationKey: "DateIsPast").localizationKey, "DateIsPast")
        XCTAssertEqual(URBNDateRule(comparisonType: .future, localizationKey: "DateIsFuture").localizationKey, "DateIsFuture")
        XCTAssertEqual(URBNBlockRule(validator: { _ in true }, localizationKey: "CustomBlockFailed").localizationKey, "CustomBlockFailed")
    }
    
    
    func testLocalizationOverrideStrings() {
        let vd = URBNValidator()
        
        let localizedError: (ValidationRule) -> String? = { (rule) -> String? in
            return vd.localizeableString(rule, key: "test", value: "value")
        }
        
        
        XCTAssertEqual(localizedError(URBNRequiredRule(localizationKey: "Required")), "ls_URBNValidator_URBNValidator.Required")
        XCTAssertEqual(localizedError(URBNMinLengthRule(minLength: 0, inclusive: true, localizationKey: "MinLength")), "ls_URBNValidator_URBNValidator.MinLength")
        XCTAssertEqual(localizedError(URBNMaxLengthRule(maxLength: 0, inclusive: true, localizationKey: "MaxLength")), "ls_URBNValidator_URBNValidator.MaxLength")
        XCTAssertEqual(localizedError(URBNRegexRule(pattern: "", localizationKey: "Regex")), "ls_URBNValidator_URBNValidator.Regex")
        XCTAssertEqual(localizedError(URBNDateRule(comparisonType: .past, localizationKey: "DateIsPast")), "ls_URBNValidator_URBNValidator.DateIsPast")
        XCTAssertEqual(localizedError(URBNDateRule(comparisonType: .future, localizationKey: "DateIsFuture")), "ls_URBNValidator_URBNValidator.DateIsFuture")
        XCTAssertEqual(localizedError(URBNBlockRule(validator: { _ in true }, localizationKey: "CustomBlockFailed")), "ls_URBNValidator_URBNValidator.CustomBlockFailed")
    }
}
