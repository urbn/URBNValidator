//
//  ValidatorRules.swift
//  URBNValidator
//
//  Created by Joseph Ridenour on 11/23/15.
//
//

import Foundation



open class URBNRequiredRule: URBNBaseRule {
    
    open override func validateValue<T>(_ value: T?) -> Bool {
        if value is String {
            /// Also validate the value is not empty here.  
            /// We're only doing this for backwards compatibility with QBValidator.
            /// We should decide if this is the way to go about this.
            return (value as! String).length > 0
        }
        return value != nil
    }
}



open class URBNNotRequiredRule: URBNBaseRule {
    
    open override func validateValue<T>(_ value: T?) -> Bool {
        return true
    }
}




public typealias BlockValidation = (_ value: Any?) -> Bool
open class URBNBlockRule: URBNBaseRule {
    open var blockValidation: BlockValidation
    
    public init(_ validator: @escaping BlockValidation) {
        blockValidation = validator
        super.init()
    }
    
    public init(validator: @escaping BlockValidation, localizationKey: String? = nil) {
        blockValidation = validator
        super.init(localizationKey: localizationKey)
    }
    
    open override func validateValue<T>(_ value: T?) -> Bool {
        return self.blockValidation(value)
    }
}



/**
 URBNDateRule validates that a date is < > than today
 
*/

@objc public enum URBNDateComparision: Int {
    case past
    case future
    
    var comparisonResult: [ComparisonResult] {
        switch(self) {
        case .past: return [ComparisonResult.orderedDescending]
        case .future: return [ComparisonResult.orderedAscending, ComparisonResult.orderedSame]
        }
    }
    
    var localizeString: String {
        switch(self) {
        case .past: return "URBNDatePastRule"
        case .future: return "URBNDateFutureRule"
        }
    }
}

open class URBNDateRule: URBNBaseRule {
    open var comparisonUnit = NSCalendar.Unit.second
    open var comparisonType = URBNDateComparision.past {
        didSet {
            // Only if we have not set the localization directly, then 
            // we'll reset our localization on change of comparisonType
            if _localizationIsOverriden == false {
                self.localizationKey = self.comparisonType.localizeString
            }
        }
    }
    
    open override var localizationKey: String {
        didSet {
            _localizationIsOverriden = true
        }
    }
    
    
    public init(comparisonType: URBNDateComparision = .past, localizationKey: String? = nil) {
        self.comparisonType = comparisonType
        _localizationIsOverriden = localizationKey != nil
        super.init(localizationKey: localizationKey ?? comparisonType.localizeString)
    }
    
    open override func validateValue<T>(_ value: T?) -> Bool {
        if value is Date {
            guard let v = value as? Date else {
                print("WARNING:  Passing \(value) to expected type of NSDate in URBNDateRule.  This is technically not allowed, but because objc let's it slide we have to support it.   You're probably doing something wrong.")
                return false
            }

            let result = (Calendar.current as NSCalendar).compare(Date(), to: v, toUnitGranularity: comparisonUnit)
            return comparisonType.comparisonResult.contains(result)
        }

        return value != nil
    }
    
    fileprivate var _localizationIsOverriden: Bool = false
}
