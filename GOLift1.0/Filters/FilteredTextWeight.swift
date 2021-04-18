//
//  FilteredTextWeight.swift
//  GOLift1.0
//
//  Created by L EE on 14/04/2021.
//

import SwiftUI
import CoreData

struct FilteredTextWeight {
   
    
   
    
    var activity = [Activity]()
    // filtering the hitory list dynamically
    init() {
        
        let f  = NSFetchRequest<NSFetchRequestResult>(entityName: "Activity")
        f.predicate = NSPredicate(format: "exerciseName == %@", "standing squat")
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


