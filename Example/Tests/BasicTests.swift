import UIKit
import XCTest
import URBNValidator

class BasicTests: XCTestCase {
    
    func testRequiredRule() {
        let r = URBNRequiredRule()
        
        XCTAssertEqual(r.localizationKey, "URBNRequiredRule", "localizationKey should default to the className")
        XCTAssertFalse(r.validateValue(nil), "Nil should be invalid")
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
        XCTAssertFalse(r.validateValue(nil))
        XCTAssertTrue(r.validateValue(0.1))
        XCTAssertTrue(r.validateValue(1))
    }
}
