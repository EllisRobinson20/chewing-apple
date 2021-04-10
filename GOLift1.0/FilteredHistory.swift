

import CoreData
import SwiftUI

struct FilteredHistory {
    var fetchRequest: FetchRequest<History>
    let predicate1:NSPredicate
    let predicate2:NSPredicate
    var history: FetchedResults<History> { fetchRequest.wrappedValue }
    // filtering the hitory list dynamically
    init(filterExercise: String, filterTarget: String ) {
        predicate1 = NSPredicate(format: "exerciseName == %@", "\(filterExercise)")
        predicate2 = NSPredicate(format: "targetName == %@", "\(filterTarget)")
        fetchRequest = FetchRequest<History>(entity: History.entity(), sortDescriptors: [
            NSSortDescriptor(keyPath: \History.date, ascending: true)
        ], predicate: NSCompoundPredicate(orPredicateWithSubpredicates: [predicate1,predicate2] ))
        //print("Testing filetered list: exercise = \(filterExercise) ,  target = \(filterTarget) result = \(fetchRequest.wrappedValue.first?.targetName)")// test the foltered list
    }
    func get() -> FetchedResults<History> {
        return history
    }
}
