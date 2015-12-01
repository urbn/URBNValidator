//: [Required Rule](@previous) [Overview](@overview)

/*:
# Length Requirements

Here we've got a built in rule to handle length requirements. 
This will verify lengths of anything that conforms to our Lengthable
protocol.   Which by default handles strings, arrays and dictionaries
*/
import URBNValidator

/*:
### Max Length

Our first length rule is a maxLength.   This says that 
the value we're validating should nto be greater than or equal to 5
*/
let maxLengthRule = URBNMaxLengthRule(maxLength: 5)


// These are all valid
maxLengthRule.validateValue([])
maxLengthRule.validateValue("")
maxLengthRule.validateValue(["": 1])
maxLengthRule.validateValue("12345")

// These are invalid
maxLengthRule.validateValue(nil)
maxLengthRule.validateValue([1,2,3,4,5,6])
maxLengthRule.validateValue("123456")


/*: 
### Min Length

Min Length is the same thing except at the bottom end. \n
The given value should be >= 5
*/
let minLengthRule = URBNMinLengthRule(minLength: 2)

// These are valid
minLengthRule.validateValue("12")
minLengthRule.validateValue("1234")
minLengthRule.validateValue([1,2])
minLengthRule.validateValue([1:1,2:2])

// These are invalid
minLengthRule.validateValue(nil)
minLengthRule.validateValue("1")
minLengthRule.validateValue([])
minLengthRule.validateValue(["1":1])

//: [Block Rules](@next)
