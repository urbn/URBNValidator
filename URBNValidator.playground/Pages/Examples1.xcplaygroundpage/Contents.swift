//: [Previous](@previous)

/*:
# Requirement 1

Our first requirement is single value validation with a given
ruleset
*/


import Foundation


@objc protocol ValidationRule {
    var localizationKey: String { get set }
    func validateValue(value: AnyObject?) -> Bool
}

class RequiredRule: ValidationRule {
    @objc var localizationKey: String = "ls_urbnv_required"
    
    @objc func validateValue(value: AnyObject?) -> Bool {
        return value != nil
    }
}


class Object {
    var string: String?
    var data: NSDate?
    var integer: Int?
}



let obj = Object()


let r = RequiredRule()
r.validateValue(obj.string)
obj.string = ""
r.validateValue(obj.string)












//: [Next](@next)
