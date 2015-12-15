//
//  ObjectTests.swift
//  URBNValidator
//
//  Created by Joseph Ridenour on 12/10/15.
//  Copyright © 2015 URBN. All rights reserved.
//

import XCTest
import URBNValidator

class Testable: Validateable {
    var rules = [String: ValidatingValue]()
    
    @objc func validationMap() -> [String : ValidatingValue] {
        return rules
    }
}

class User: Testable {
    var firstName = ""
    var lastName: String?
    var addresses = [String]()
    
    override func validationMap() -> [String : ValidatingValue] {
        rules = rules.count > 0 ? rules : [
            "firstName": ValidatingValue(value: self.firstName, rules: URBNRequiredRule(), URBNMinLengthRule(minLength: 2, inclusive: true)),
            "lastName": ValidatingValue(value: self.lastName, rules: URBNNotRequiredRule(), URBNMinLengthRule(minLength: 2, inclusive: true)),
            "addresses": ValidatingValue(value: self.addresses, rules: URBNNotRequiredRule(), URBNMinLengthRule(minLength: 1, inclusive: true))
        ]
        return super.validationMap()
    }
}

class ObjectTestsSwifty: XCTestCase {
    var vd = URBNValidator()
    
    func testSingleError() {
        let u = User()
        u.firstName = "Joe"
        
        do {
            try vd.validate(u, stopOnFirstError: true)
        }
        catch let err as NSError {
            XCTAssertEqual(err.domain, ValidationErrorDomain, "Validation error domain should be proper")
            XCTAssertEqual(err.code, ValidationError.FieldInvalid.rawValue, "Should be single field validation error")
            XCTAssertEqual(err.localizedDescription, "ls_URBNValidator_URBNMinLengthRule")
        }
        catch {
            XCTFail("This should not happen")
        }
    }
    
    func testMultiError() {
        let u = User()
        u.lastName = "1"
        u.addresses = []
        
        do {
            try vd.validate(u)
        }
        catch let err as NSError {
            XCTAssertEqual(err.domain, ValidationErrorDomain, "Validation error domain should be proper")
            XCTAssertEqual(err.code, ValidationError.MultiFieldInvalid.rawValue, "Should be multiple field validation error")
            XCTAssertEqual(err.underlyingErrors?.count, 4, "Should have 1 error for each validation rule")
        }
        catch {
            XCTFail("Should not happen")
        }
    }
    
    
    /**
     By default URBNValidator will add an implicit URBNRequiredRule if there is not an URBNRequiredRule or 
     URBNNotRequiredRule.
    */
    func testImplicitErrors() {
        let t = Testable()
        
        // This is the same things as specifying `URBNRequiredRule(), URBNMinLengthRule(minLength: 3)`
        t.rules = ["prop1": ValidatingValue(value: nil, rules: URBNMinLengthRule(minLength: 3))]
        
        do {
            try vd.validate(t)
        }
        catch let err as NSError {
            let fieldErrors = err.underlyingErrors!
            XCTAssertEqual(fieldErrors.count, 2, "Should only have 2 errors")
            XCTAssertEqual(fieldErrors[0].localizedDescription, "prop1 is required.")
            XCTAssertEqual(fieldErrors[1].localizedDescription, "ls_URBNValidator_URBNMinLengthRule")
        }
        catch {
            XCTFail("Should never happen")
        }
        
        
        
        // This says that prop1 is not required, but if it's non-nil, then the length
        // should be > 3
        t.rules = ["prop1": ValidatingValue(value: nil, rules: URBNNotRequiredRule(), URBNMinLengthRule(minLength: 3))]
        
        do {
            try vd.validate(t)
            XCTAssertTrue(true, "This should not fall through to the catch")
        }
        catch {
            XCTFail("Should never happen")
        }
    }
    
}