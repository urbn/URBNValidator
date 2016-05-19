import UIKit
import XCTest
import URBNValidator

class BasicTests: XCTestCase {
    
    func testRequiredRule() {
        let r = URBNRequiredRule()
        
        XCTAssertEqual(r.localizationKey, "URBNRequiredRule", "localizationKey should default to the className")
        XCTAssertFalse(r.validateValue(nil as AnyObject?), "Nil should be invalid")
        XCTAssertTrue(r.validateValue("-"), "Non-nil should be valid")
    }
    
    func testMinLengthRule() {
        let r = URBNMinLengthRule(minLength: 5, inclusive: true)
        
        XCTAssertEqual(r.localizationKey, "URBNMinLengthRule")
        XCTAssertFalse(r.validateValue("1234"))
        XCTAssertTrue(r.validateValue("12345"))
        
        // Validate arrays
        XCTAssertTrue(r.validateValue([1,2,3,4,5]))
        XCTAssertFalse(r.validateValue([]))
        
        // Validate dictionaries
        XCTAssertTrue(r.validateValue(["1":1,"2":2,"3":3,"4":4,"5":5]))
        XCTAssertFalse(r.validateValue(["1":1]))
    }
    
    func testMaxLengthRule() {
        let r = URBNMaxLengthRule(maxLength: 5, inclusive: true)
        
        XCTAssertEqual(r.localizationKey, "URBNMaxLengthRule")
        XCTAssertTrue(r.validateValue("1234"))
        XCTAssertFalse(r.validateValue("123456"))
        
        // Validate arrays
        XCTAssertFalse(r.validateValue([1,2,3,4,5,6]))
        XCTAssertTrue(r.validateValue([]))
        
        // Validate dictionaries
        XCTAssertFalse(r.validateValue(["1":1,"2":2,"3":3,"4":4,"5":5,"6":6]))
        XCTAssertTrue(r.validateValue(["1":1]))
    }
    
    func testBlockRule() {
        let r = URBNBlockRule { (value) -> Bool in
            return value is Int
        }
        
        XCTAssertEqual(r.localizationKey, "URBNBlockRule")
        XCTAssertFalse(r.validateValue(nil as AnyObject?))
        XCTAssertFalse(r.validateValue(0.1))
        XCTAssertTrue(r.validateValue(1))
    }
    
    func testDateRule() {
        let r = URBNDateRule()
        
        XCTAssertEqual(r.localizationKey, "URBNDatePastRule")
        XCTAssertEqual(r.comparisonType, URBNDateComparision.Past, "Should default to past")
        
        r.comparisonType = URBNDateComparision.Past
        XCTAssertTrue(r.validateValue(NSDate().dateByAddingTimeInterval(-100)), "Should validate past when comparisonType == .Past")
        XCTAssertFalse(r.validateValue(NSDate().dateByAddingTimeInterval(100)), "Should not validate future when comparisonType == .Past")
        
        r.comparisonType = URBNDateComparision.Future
        XCTAssertTrue(r.validateValue(NSDate().dateByAddingTimeInterval(100)), "Should validate future when comparisonType == .Ascending")
        XCTAssertFalse(r.validateValue(NSDate().dateByAddingTimeInterval(-100)), "Should not validate past when comparisonType == .Ascending")
        
        // Month/Year only
        r.comparisonUnit = NSCalendarUnit.Month
        XCTAssertTrue(r.validateValue(NSDate().dateByAddingTimeInterval(-100)), "Should validate when the comparison unit is set to Month")
    }
    
    func testRegexRule() {
        let r = URBNRegexRule(pattern: "(?<![a-z-#.\\d\\p{Latin}])[a-z-#.\\d\\p{Latin}][a-z-#.\\d\\s\\p{Latin}]+")
        r.isRequired = false
        
        XCTAssertEqual(r.localizationKey, "URBNRegexRule")
        
        XCTAssertFalse(r.validateValue(""), "Should validate empty when required is off")
        XCTAssertFalse(r.validateValue(" "), "Should not validate")
        
        XCTAssertTrue(r.validateValue("123 Test Rd."), "Should validate address")
    }
    
}
