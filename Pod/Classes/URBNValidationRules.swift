//
//  ValidatorRules.swift
//  URBNValidator
//
//  Created by Joseph Ridenour on 11/23/15.
//
//

import Foundation



public class URBNRequiredRule: URBNBaseRule {
    
    public override func validateValue<T>(value: T?) -> Bool {
        if value is String {
            /// Also validate the value is not empty here.  
            /// We're only doing this for backwards compatibility with QBValidator.
            /// We should decide if this is the way to go about this.
            return (value as! String).length > 0
        }
        return value != nil
    }
}



public class URBNNotRequiredRule: URBNBaseRule {
    
    public override func validateValue<T>(value: T?) -> Bool {
        return true
    }
}




public typealias BlockValidation = (value: Any?) -> Bool
public class URBNBlockRule: URBNBaseRule {
    public var blockValidation: BlockValidation
    
    public init(_ validator: BlockValidation) {
        blockValidation = validator
        super.init()
    }
    
    public init(validator: BlockValidation, localizationKey: String? = nil) {
        blockValidation = validator
        super.init(localizationKey: localizationKey)
    }
    
    public override func validateValue<T>(value: T?) -> Bool {
        return self.blockValidation(value: value)
    }
}



/**
 URBNDateRule validates that a date is < > than today
 
*/

@objc public enum URBNDateComparision: Int {
    case Past
    case Future
    
    var comparisonResult: [NSComparisonResult] {
        switch(self) {
        case .Past: return [NSComparisonResult.OrderedDescending]
        case .Future: return [NSComparisonResult.OrderedAscending, NSComparisonResult.OrderedSame]
        }
    }
    
    var localizeString: String {
        switch(self) {
        case .Past: return "URBNValidator.URBNDatePastRule"
        case .Future: return "URBNValidator.URBNDateFutureRule"
        }
    }
}

public class URBNDateRule: URBNBaseRule {
    public var comparisonUnit = NSCalendarUnit.Second
    public var comparisonType = URBNDateComparision.Past {
        didSet {
            // Only if we have not set the localization directly, then 
            // we'll reset our localization on change of comparisonType
            if _localizationIsOverriden == false {
                self.localizationKey = self.comparisonType.localizeString
            }
        }
    }
    
    public override var localizationKey: String {
        didSet {
            _localizationIsOverriden = true
        }
    }
    
    
    public init(comparisonType: URBNDateComparision = .Past, localizationKey: String? = nil) {
        self.comparisonType = comparisonType
        _localizationIsOverriden = localizationKey != nil
        super.init(localizationKey: localizationKey ?? comparisonType.localizeString)
    }
    
    public override func validateValue<T: NSDate>(value: T?) -> Bool {
        guard let value = value as? NSDate else { return false }
        
        let result = NSCalendar.currentCalendar().compareDate(NSDate(), toDate: value, toUnitGranularity: comparisonUnit)
        return comparisonType.comparisonResult.contains(result)
    }
    
    private var _localizationIsOverriden: Bool = false
}
