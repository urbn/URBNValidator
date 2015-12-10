//: [Block Rules](@previous)

/*:
# Object Validation

This is what it's all about.  Here we're 
giving a map of keys to rules, and validating against them
*/

import Foundation
import URBNValidator

class Tester: Validateable {
    var requiredString: String?
    var children = [String]()
    
    @objc func validationMap() -> [String : ValidatingValue] {
        return [
            "requiredString": ValidatingValue(value: self.requiredString, rules: URBNRequiredRule()),
            "children": ValidatingValue(value: self.children, rules: URBNMinLengthRule(minLength: 3))
        ]
    }
    
    @objc func valueForKey(key: String) -> AnyObject? {
        let d: [String: AnyObject?] = [
            "requiredString": self.requiredString,
            "children": self.children
        ]
        return d[key]!
    }
}

let obj = Tester()

let validator = URBNValidator()

do {
    try validator.validate(obj)
}
catch let err as NSError {
    print(err.underlyingErrors!.map({ $0.localizedDescription }))
}

//: [Next](@next)
