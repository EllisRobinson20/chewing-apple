//
//  Workout.swift
//  GOLift1.0
//
//  Created by L EE on 06/04/2021.
//

import SwiftUI
import CoreData



struct Workout{
    
    @FetchRequest(sortDescriptors: [])
    private var activities: FetchedResults<Activity>
    @Environment(\.managedObjectContext) private var viewContext
    
    var myWorkout = [String]()
    
    func setRepMax(chosenExercise: String, maxKG: Float, repsCount: Int) {
        // calc the rep max on chosen activity
        // check activites db for previous entries
        //then compare them
            //if new on is less than old one as user if sure wants to update
            // if not update and give message "your rep max has gone up by X"
        //after this method call the view needs to update depending on which target was picked
        // so here there needs to be some state managment 
        
            print("Setting rep max")
            let oneRepMax = maxKG / (1.0278 - 0.0278 * Float(repsCount) )
            if !activities.isEmpty {
                //
                print("Setting rep max2")
                for activity in activities {
                    print("TWO")
                if helper.userSession.contains( chosenExercise ) {
                activity.oneRepMax = oneRepMax
                ContentView().saveDB() //make sure one rep max saves even though estTenReps does so automatically
                estTenRepKG(repMax: oneRepMax, activity: activity)
                }
                }
            } else {
                print("Setting rep max3")
                
                if helper.userSession.contains( chosenExercise ) {
                    let newActivity = Activity(context: viewContext)
                newActivity.oneRepMax = oneRepMax
                ContentView().saveDB() //make sure one rep max saves
                estTenRepKG(repMax: oneRepMax, activity: newActivity)
                }
            }
        
    }
    
    func estTenRepKG(repMax: Float, activity: Activity) {
        let tenRepMax = repMax / 100 * 75
        activity.estTenRepsKG = tenRepMax
        ContentView().saveDB()
    }
    func validate(exercise: String) -> Bool {
        
        var res = true
        for activity in activities {
            print(activity.oneRepMax)
            print(String(activity.exerciseName!))
            if activity.exerciseName == exercise && activity.oneRepMax > 0 {
                
                res = true
                print("this not working")
            } else {
                res = false
            }
        }
        return res
    }
}
