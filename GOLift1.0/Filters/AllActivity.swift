

import CoreData
import SwiftUI

struct AllActivity {
    
    var activity = [Activity]()
    // filtering the hitory list dynamically
    init() {
        
        let f  = NSFetchRequest<NSFetchRequestResult>(entityName: "Activity")
        do {
        activity = try PersistenceController.shared.container.viewContext.fetch(f) as! Array<Activity>
        }
        catch {
        }
    }
    func get() -> [Activity] {
        return activity
    }
}
