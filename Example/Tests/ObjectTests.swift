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
    typealias V = Lengthable
    var rules = [String: ValidatingValue<V>]()
    
    func validationMap() -> [String : ValidatingValue<V>] {
        return rules
    }
}

class User: Testable {
    var firstName = ""
    var lastName: String?
    var addresses = [String]()
    
    override var rules: [String: ValidatingValue<V>] {
        get {
            if super.rules.isEmpty {
                super.rules = [
                    "firstName": ValidatingValue(value: self.firstName, rules: URBNRequiredRule(), URBNMinLengthRule(minLength: 2, inclusive: true)),
                    "lastName": ValidatingValue(value: self.lastName, rules: URBNNotRequiredRule(), URBNMinLengthRule(minLength: 2, inclusive: true)),
                    "addresses": ValidatingValue(value: self.addresses, rules: URBNNotRequiredRule(), URBNMinLengthRule(minLength: 1, inclusive: true))
                ]
            }
            
            return super.rules
        }
        set {
            super.rules = newValue
        }
    }
}

struct TestItem: Validateable {
    typealias V = AnyObject
    var prop1: String
    
    
    func validationMap() -> [String : ValidatingValue<V>] {
        return [
            "prop1": ValidatingValue(value: self.prop1, rules: URBNNotRequiredRule(), URBNRegexRule(pattern: "(?<![a-z-#.\\d\\p{Latin}])[a-z-#.\\d\\p{Latin}][a-z-#.\\d\\s\\p{Latin}]+"))
        ]
    }
}
class ValidatorTests: XCTestCase {    
    func testNotRequired () {
        
        let vd = URBNValidator()
        let item = TestItem(prop1: "")
        
        var error: NSError? = nil
        do {
            try vd.validate(item)
        } catch let err as NSError {
            error = err
        }
        XCTAssertEqual(error!.domain, ValidationErrorDomain, "Should be ValidationErrorDomain")
        XCTAssertEqual(error!.code, ValidationError.MultiFieldInvalid.rawValue, "Should be single field error type")
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
            XCTAssertEqual(err.localizedDescription, "too short")
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
            XCTAssertEqual(fieldErrors[1].localizedDescription, "too short")
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
    
    
    func testCustomLocalizations() {
        let t = Testable()
        
        t.rules = [
            "prop1":
                ValidatingValue(value: nil,
                rules:
                URBNRequiredRule(localizationKey: "t_required"),
                URBNBlockRule(validator: { $0 is Int }, localizationKey: "t_integer"))]
        
        do {
            try vd.validate(t)
            XCTFail("Should not validate")
        } catch let err as NSError {
            XCTAssertEqual(err.underlyingErrors!.count, 2)
            XCTAssertEqual(err.underlyingErrors![0].localizedDescription, "ls_URBNValidator_t_required")
            XCTAssertEqual(err.underlyingErrors![1].localizedDescription, "ls_URBNValidator_t_integer")
        }
    }
}
