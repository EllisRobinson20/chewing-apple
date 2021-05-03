

import CoreData
import SwiftUI

struct AllActivity {
    
    var activity = [Activity]()
    init() {
        
        let f  = NSFetchRequest<NSFetchRequestResult>(entityName: "Activity")
        do {
            activity = try PersistenceController.shared.container.viewContext.fetch(f) as! Array<Activity>
        }
        catch {
        }
    }
    func get() -> [Activity] {
        print("VALUES RETURNED FROM AllActivity: \(activity)")
        return activity
    }
}
