
//
//  URBNLengthRulesCompat.swift
//  Pods
//
//  Created by Nick DiStefano on 12/21/15.
//
//

import Foundation

@objc public class CompatMinLR: CompatBaseRule {
    public init(minLength: Int, inclusive: Bool = false, localizationKey: String? = nil) {
        super.init()
        self.baseRule = URBNMinLengthRule(minLength: minLength, inclusive: inclusive, localizationKey: localizationKey)
    }
}

@objc public class CompatMaxLR: CompatBaseRule {
    public init(maxLength: Int, inclusive: Bool = false, localizationKey: String? = nil) {
        super.init()
        self.baseRule = URBNMaxLengthRule(maxLength: maxLength, inclusive: inclusive, localizationKey: localizationKey)
    }
}