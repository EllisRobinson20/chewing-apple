import CoreData
import SwiftUI

struct FilteredExerciseState {
    
    var state = [ExerciseState]()
    // filtering the hitory list dynamically
    init() {
        
        let f  = NSFetchRequest<NSFetchRequestResult>(entityName: "ExerciseState")
        do {
        state = try PersistenceController.shared.container.viewContext.fetch(f) as! Array<ExerciseState>
        }
        catch {
        }
    }
    func get() -> [ExerciseState] {
        return state
    }
}
