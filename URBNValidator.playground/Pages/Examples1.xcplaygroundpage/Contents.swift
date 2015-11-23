//: [Previous](@previous)

/*:
# Requirement 1

Our first requirement is single value validation with a given
ruleset
*/


//: Create the rule
let r = URBNRequiredRule()

//: Calling the required rule with something that's nil will be invalid
r.validateValue(nil)

//: Passing a valid non-nil object will result valid
r.validateValue("")

//: You may also optionally pass a localized_key override here
r.validateValue(nil, key: "test_localized")

//: [Next](@next)
