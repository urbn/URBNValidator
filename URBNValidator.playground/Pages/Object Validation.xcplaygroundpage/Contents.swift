//: [Block Rules](@previous)

/*:
# Object Validation

This is what it's all about.  Here we're 
giving a map of keys to rules, and validating against them
*/

import Foundation

class Tester: Validateable {
    var requiredString: String?
    var children = [String]()
    
    @objc func validationMap() -> [String : [ValidationRule]] {
        return [
            "requiredString": [URBNRequiredRule()]
        ]
    }
}

let obj = Tester()

let validator = URBNValidator()

validator.validateValue(obj.requiredString, rules: [URBNRequiredRule()])

//: [Next](@next)
