//: [Required Rule](@previous) [Overview](@overview)

/*:
# Length Requirements

Here we've got a built in rule to handle length requirements. 
This will verify lengths of anything that conforms to our Lengthable
protocol.   Which by default handles strings, arrays and dictionaries. 

By default length rules are non-inclusive.   Meaning the greater 
than matches '>' and less than '<'.   If you'd like the rule to be 
inclusive '>=' or '<=', then you can include the optional `inclusive` 
param on init.   Optionally you can set the .isInclusive property
*/
import URBNValidator

/*:
### Max Length

Our first length rule is a maxLength.   This says that 
the value we're validating should nto be greater than 5
*/
let maxLengthRule = URBNMaxLengthRule(maxLength: 5)


// These are all valid
maxLengthRule.validateValue([])
maxLengthRule.validateValue("")
maxLengthRule.validateValue(["": 1])
maxLengthRule.validateValue("12345")

// With inclusive
maxLengthRule.isInclusive = true
maxLengthRule.validateValue("12345")

/*:
For the anything that is `URBNRequirement` we specify 
an isRequired flag.  The purpose of `isRequired` is to 
let the rule know whether or not it accepts nil.   If required,
then nil will not be valid
*/
maxLengthRule.isRequired = true
maxLengthRule.validateValue(nil)    // Not Valid because isRequired=true
maxLengthRule.isRequired = false
maxLengthRule.validateValue(nil)    // Valid


// These are invalid
maxLengthRule.validateValue([1,2,3,4,5,6])
maxLengthRule.validateValue("123456")


/*: 
### Min Length

Min Length is the same thing except at the bottom end.
The given value should be > 5
*/
let minLengthRule = URBNMinLengthRule(minLength: 2, inclusive: true)

// These are valid
minLengthRule.validateValue("12")
minLengthRule.validateValue("1234")
minLengthRule.validateValue([1,2])
minLengthRule.validateValue([1:1,2:2])

// These are invalid
minLengthRule.validateValue("1")
minLengthRule.validateValue([])
minLengthRule.validateValue(["1":1])

// Requirements
minLengthRule.isRequired = true
minLengthRule.validateValue(nil)    // Not Valid because isRequired=true
minLengthRule.isRequired = false
minLengthRule.validateValue(nil)    // Valid


//: [Block Rules](@next)
