//: [Previous](@previous)

/*:
# Requirement 1

Our first requirement is single value validation with a given
ruleset
*/

import URBNValidator

//: Create the rule
let r = URBNRequiredRule()

//: Calling the required rule with something that's nil will be invalid
r.validateValue(nil)

/*:
Passing an object will validate in the following conditions.

- The object is non-nil
- If object is a string it has length > 0
*/
r.validateValue("") // 👍
r.validateValue("-") // 👎

//: You may also optionally pass a localized_key override here
r.validateValue(nil, key: "test_localized")

//: [Length Rules](@next)
