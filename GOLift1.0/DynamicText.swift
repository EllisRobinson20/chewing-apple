//
//  DynamicText.swift
//  GOLift1.0
//
//  Created by L EE on 09/04/2021.
//

import SwiftUI
import CoreData


struct DynamicText: View {
    //var fetchRequest: FetchRequest<Activity>
    //var fetchHistory: FetchRequest<History>
    //var num = 0
    // Will have to set helper at the time of lifcycle end to refresh the main view state
    
    //If problems with the updates then add the whole ui promtinng ui into this view, move code from init
    // to a method call then call the method cal inside each text node
    
    //Ideally this struct will have class properties which return numbers to helper
    //this will help later when the tet nodes have changed the data to string values (NOTE: The view may be attached to helper class properties. Thes State varables in the main ui view are theoretically able to respond when this class wants to return data
    //this also means there may be no need for any direct return values to main ui)
    //Be careful setting view and helper seperately as each must be consistent eg class property cerrentRepMax has already been set
    //If it good for update? or does it need to wait for the filter to return first?
    @State var currentRepMax = 3
    @State var s = ""
    
    var body: some View {
        Text(String(s))
        
        //Text(String(fetchRequest.wrappedValue.first?.exerciseName ?? "nill"))
    }
    
    init(target: String, activityName: String, textNode: String) {
        // get the most recent history relevant to exercise name and target
        let historyResult = getLastHistory(filterExercise: activityName, filterTarget: target)
        // This result needs to be converted to fetchedResult
        var historyFetched: FetchedResults<History> {historyResult.wrappedValue}
        // if it in nill
        if historyResult.wrappedValue.isEmpty {
            // set and get from activity (see notes)
            //num = historyResult.wrappedValue.first?.repsAchieved as! Int
            let activityResult = getActivity(exerciseName: activityName)
            if !activityResult.wrappedValue.isEmpty {
                // Value for the view state
                currentRepMax = Int(activityResult.wrappedValue.first?.oneRepMax ?? 0)
                // now update the improvement index with setActivityIndex
                setActivityIndex(index: 0, exerciseName: activityName)
            }
            // Now filter the blanks depending on the values ...
            // First get the static Target from targets.json
            let targetObj = getTargetObj(name: target)
            // Then get activity object with getActivityObject
            let activityObject = getActivityObject(exerciseName: activityName)
            // Dont forget to keep th state will with helper for DB to be able to read on rtn from the filter
            
            //Filter method is next NOTE: need variables that are in class level scope rather than local
            s = filter(forNode: textNode, fetchedResults: historyFetched, currentActivity: activityObject, targetObj: targetObj!)

        }
 //
        
        
        
         
        
        
        
//        fetchRequest = FetchRequest<Activity>(entity: Activity.entity(), sortDescriptors: [], predicate: NSPredicate(format: "exerciseName == %@", name ))
    }
    
    func filter(forNode: String, fetchedResults: FetchedResults<History>, currentActivity: Activity, targetObj: Target) -> String {
       var targetKG: Float = 0 //to class level
       var targetReps: Int = 0 // to class level
       var result = ""
       switch forNode {
       case "kg":
           // if rep max bigger than index
           if Int16(currentActivity.oneRepMax) > currentActivity.improvementIndex && currentActivity.improvementIndex > 0 {
               targetKG = currentActivity.oneRepMax * (Float(targetObj.oneRepMax[0])  / 100)
           }else
           if currentActivity.improvementIndex >= Int16(currentActivity.oneRepMax) {
               targetKG = Float(currentActivity.improvementIndex) * (Float(targetObj.oneRepMax[0])  / 100)
           }
           result = String(targetKG)
           break
       //if index bigger than rep max
       case "rep":
           // will need to check the history, newest entry of reps achieved
           if fetchedResults.first != nil {
               print("Workout.swift: result not nil")
               let nsObj = fetchedResults.first?.repsAchieved
               let arr1 = NSArray(objects: nsObj ?? NSArray())
               let objCArray = NSMutableArray(array: arr1)
               let swiftArray: [Int] = objCArray.compactMap({ $0 as? Int })
               targetReps = getSuggestedRepCount(array: swiftArray)
               print("The array to print: \(swiftArray)")
               // need to get that rep counter and from that transformable
               
           } else {
               print("Workout.swift: result is nil")
               targetReps = targetObj.targetSets[0]
           }
           result = String(targetReps)
           break
       //get a median and the highest and the lowest - if the median is lower than 50% low to high
       //use median - if median is 50% or higher than the low to high range - then use highest figure
       // an even median would mean taking two middle numbers doing a+b/2
       //ALSO if no history then will have to assume the middle of the suggested target (filtered) weight
       case "setcount":
//to class level with total sales current speed interval timemax
           let totalSets = targetObj.targetSets[1]
           result = String(totalSets)
           break
       case "speed":
           let currentSpeed = targetObj.speed
           result = String(currentSpeed)
           break
       case "interval":
           let intervalTimeMax = targetObj.interval[1]
           result = String(intervalTimeMax)
           break
       default:
           break
       }
       return result
   }
   
   func getSuggestedRepCount(array: [Int]) -> Int {
       let result: Int
       let median: Int
       let arraySize = array.count
       let sortedArray = array.sorted()
       if isEven(number: arraySize) && arraySize > 0 { // check bigger than zero for crash operators below
           median = Int((Double(arraySize)*0.5)+1)
       } else {
           median = Int((Double(arraySize)*0.5)+0.5)
       }
       if array[median] > sortedArray.last! - sortedArray.first! {
           result = sortedArray.last!
       } else {
           result = array[median]
       }
       return result
   }
   // will need an overide of the getsuggested reps function for when the weight gets changed and the suggested rep count can change with the weight count
   func isEven(number: Int) -> Bool {
       if number % 2 == 0 {
           return true
       } else {
           return false
       }
   }
   
   
   
    
    
    
    //Get most recent and relevant history record
    func getLastHistory(filterExercise: String, filterTarget: String) -> FetchRequest<History> {
        let predicate1 = NSPredicate(format: "exerciseName == %@", "\(filterExercise)")
        let predicate2 = NSPredicate(format: "targetName == %@", "\(filterTarget)")
        let fetchHistory = FetchRequest<History>(entity: History.entity(), sortDescriptors: [
            NSSortDescriptor(keyPath: \History.date, ascending: true)
        ], predicate: NSCompoundPredicate(orPredicateWithSubpredicates: [predicate1,predicate2] ))
        return fetchHistory
    }
    
    func setActivityIndex(index: Int, exerciseName: String) {
        // get the view/object context
        let managedContext = PersistenceController.shared.container.viewContext
        let fetchActivity:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Activity")
        fetchActivity.predicate = NSPredicate(format: "exerciseName == %@", exerciseName )
        //let fetchActivity = FetchRequest<Activity>(entity: Activity.entity(), sortDescriptors: [], predicate: NSPredicate(format: "exerciseName == %@", exerciseName ))
        do {
            let objectContext = try managedContext.fetch(fetchActivity)
            
            let activityUpdate = objectContext[0] as! NSManagedObject
            activityUpdate.setValue(index, forKey: "improvementIndex")
            // Double check this save !!!!!!
            PersistenceController.shared.save()
        } catch {
            print(error)
        }
    }
    
    func getActivity(exerciseName: String)  -> FetchRequest<Activity>  {
        
        let fetchActivity = FetchRequest<Activity>(entity: Activity.entity(), sortDescriptors: [], predicate: NSPredicate(format: "exerciseName == %@", exerciseName ))
        return fetchActivity
    }
    //
    func getActivityObject(exerciseName: String) -> Activity {
        // get the view/object context
        var activityObject: NSManagedObject = Activity() as NSManagedObject
        let managedContext = PersistenceController.shared.container.viewContext
        let fetchActivity:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "Activity")
        fetchActivity.predicate = NSPredicate(format: "exerciseName == %@", exerciseName )
        //let fetchActivity = FetchRequest<Activity>(entity: Activity.entity(), sortDescriptors: [], predicate: NSPredicate(format: "exerciseName == %@", exerciseName ))
        do {
            let objectContext = try managedContext.fetch(fetchActivity)
            
            activityObject = objectContext[0] as! NSManagedObject
            
            return activityObject as! Activity
        } catch {
            print(error)
        }
        return activityObject as! Activity
    }
    
    
    ///App data
    private mutating func getTargetObj(name: String) -> Target? {
        var targetObj: Target?
        for target in AppData().targets.targetsList {
            if target.targetName == name {
                targetObj = target
            }
        }
        return targetObj
    }
    
    
    
    
}


