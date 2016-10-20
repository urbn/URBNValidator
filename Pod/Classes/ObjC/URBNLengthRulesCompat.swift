
//
//  URBNLengthRulesCompat.swift
//  URBNValidator
//
//  Created by Nick DiStefano on 12/21/15.
//
//

import Foundation

@objc open class URBNCompatMinLengthRule: URBNCompatRequirementRule {
    public init(minLength: Int, inclusive: Bool = false, localizationKey: String? = nil) {
        super.init()
        backingRule = URBNMinLengthRule(minLength: minLength, inclusive: inclusive, localizationKey: localizationKey)
    }
}

@objc open class URBNCompatMaxLengthRule: URBNCompatRequirementRule {
    public init(maxLength: Int, inclusive: Bool = false, localizationKey: String? = nil) {
        super.init()
        backingRule = URBNMaxLengthRule(maxLength: maxLength, inclusive: inclusive, localizationKey: localizationKey)
    }
}
