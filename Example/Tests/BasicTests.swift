import UIKit
import XCTest
import URBNValidator

class BasicTests: XCTestCase {
    
    func testRequiredRule() {
        XCTAssertFalse(URBNRequiredRule().validateValue(nil))
        XCTAssertTrue(URBNRequiredRule().validateValue(""))
    }
}
