import CoreData
import SwiftUI

/// A value transformer which transforms `UIColor` instances into data using `NSSecureCoding`.
@objc(HistoryArrayValueTransformer)
public final class HistoryArrayValueTransformer: ValueTransformer {
    
    override public class func transformedValueClass() -> AnyClass {
        return UIColor.self
    }

    override public class func allowsReverseTransformation() -> Bool {
        return true
    }
}

public class HistoryArray : NSArray {
    
}
