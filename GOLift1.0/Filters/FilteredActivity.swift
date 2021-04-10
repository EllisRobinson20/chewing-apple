

import CoreData
import SwiftUI

class FilteredActivity: NSManagedObject, Identifiable {
    @NSManaged public var exerciseName: String?
    @NSManaged public var oneRepMax: NSObject?
    @NSManaged public var estTenRepKG: NSObject?
    @NSManaged public var improvementIndex: NSObject?
}

extension FilteredActivity {
    // ❇️ The @FetchRequest property wrapper in the ContentView will call this function
    static func fetchOne(filterExercise: String, filterTarget: String) -> NSFetchRequest<Activity> {
        let predicate1 = NSPredicate(format: "exerciseName == %@", "\(filterExercise)")
        let predicate2 = NSPredicate(format: "targetName == %@", "\(filterTarget)")
        let request: NSFetchRequest<Activity> = FilteredActivity.fetchRequest() as! NSFetchRequest<Activity>
        
        // ❇️ The @FetchRequest property wrapper in the ContentView requires a sort descriptor
        request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate1,predicate2] )
          
        return request
    }
}














//
//var activity = [Activity]()
//// filtering the hitory list dynamically
//private let predicate:NSPredicate
//init(filterExercise: String, filterTarget: String ) {
//    predicate = NSPredicate(format: "exerciseName == %@", "\(filterExercise)")
//    let f  = NSFetchRequest<NSFetchRequestResult>(entityName: "Activity", predicate: predicate)
//    do {
//    activity = try PersistenceController.shared.container.viewContext.fetch(f) as! Array<Activity>
//    }
//    catch {
//    }
//    print("Testing filetered Activity: exercise = \(filterExercise) ,  target = \(filterTarget) result = \(fetchRequest.wrappedValue.first?.exerciseName)")// test the filtered list
//}
//func get() -> [Activity] {
//    return activity
//}
