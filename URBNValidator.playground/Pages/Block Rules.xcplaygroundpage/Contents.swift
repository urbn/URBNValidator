//: [Length Rules](@previous)


/*:
# Block Rules

Now we're getting into the fun stuff.   This is a simple rule
that takes a closure which returns true or false to determine
validity.
*/


// We'll expand this for clarity.   Below is a better example of usage of 
// this kind of rule in swift
let blockRule = URBNBlockRule { (value) -> Bool in
    
    if value is String && (value as! String) == "valid" {
        return true
    }
    
    return false
}

blockRule.validateValue(nil)
blockRule.validateValue("")
blockRule.validateValue([])
blockRule.validateValue("valid")


//: With some fancy swift style things.
let floatRule = URBNBlockRule(validator: { $0 is Float })

floatRule.validateValue(nil)
floatRule.validateValue("")
floatRule.validateValue(1)
floatRule.validateValue(-1)
floatRule.validateValue([])

//: [Next](@next)
