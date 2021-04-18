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
    @State var currentRepMax = 0
    @State var s = ""
    @State var currentImprovementIndex = 0
    
    var body: some View {
        Text(String(s))
            .onAppear() {
                
            }
        
        //Text(String(fetchRequest.wrappedValue.first?.exerciseName ?? "nill"))
    }
    
    init(placeholder: String, target: String, textNode: String, historyContext: FetchedResults<History>, activityContext: Activity) {
        // get the most recent history relevant to exercise name and target
        
        // This result needs to be converted to fetchedResult
        
        // if it in nill
        if historyContext.isEmpty {
            // set and get from activity (see notes)
            //num = historyResult.wrappedValue.first?.repsAchieved as! Int
            print("Activity name in DV.init() \(String(describing: activityContext.exerciseName))")
            if activityContext.exerciseName != nil {
                // Value for the view state
                // Keep all the calculations local
                currentRepMax = Int(activityContext.oneRepMax )
                print("\(currentRepMax)")
                // now update the improvement index with setActivityIndex
                //!! Setting activity may need to be done in main ui eg set the helper then do a save context on the button presses
                setActivityIndex(index: 0, activity: activityContext)
               
            }
            
            
            //
            // Now filter the blanks depending on the values ...
            // First get the static Target from targets.json
            let targetObj = getTargetObj(name: target)
            // Then get activity object with getActivityObject
                //let activityObject = getActivityObject(exerciseName: activityName)
            // Dont forget to keep th state will with helper for DB to be able to read on rtn from the filter
            
            //Filter method is next NOTE: need variables that are in class level scope rather than local
            s = filter(forNode: textNode, currentHistory: historyContext, currentActivity: activityContext, targetObj: targetObj!)
        }
 //
        
        
        
         
        
        
        
//        fetchRequest = FetchRequest<Activity>(entity: Activity.entity(), sortDescriptors: [], predicate: NSPredicate(format: "exerciseName == %@", name ))
    }
    
    func filter(forNode: String, currentHistory: FetchedResults<History>, currentActivity: Activity, targetObj: Target) -> String {
       var targetKG: Float = 0 //to class level
       var targetReps: Int = 0 // to class level
       var result = ""
       switch forNode {
       case "kg":
           // if rep max bigger than index
        //Test for call from UI
        print("kg called")
           if Int16(currentActivity.oneRepMax) > currentActivity.improvementIndex && currentActivity.improvementIndex > 0 {
               targetKG = currentActivity.oneRepMax * (Float(targetObj.oneRepMax[0])  / 100)
            print("1.target kg set to : \(targetKG)")
           }else
           if currentActivity.improvementIndex >= Int16(currentActivity.oneRepMax) {
               targetKG = Float(currentActivity.improvementIndex) * (Float(targetObj.oneRepMax[0])  / 100)
            print("2.target kg set to : \(targetKG)")
           }
           result = String(targetKG)
           break
       //if index bigger than rep max
       case "rep":
           // will need to check the history, newest entry of reps achieved
        if  !currentHistory.isEmpty {
               print("Workout.swift: result not nil")
            let nsObj = currentHistory.first?.repsAchieved
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

    func setActivityIndex(index: Int, activity: Activity) {
        // get the view/object context
        activity.setValue(index, forKey: "improvementIndex")
        print("activity improvement index has been altered to: \(activity.improvementIndex)")
        currentImprovementIndex = Int(activity.improvementIndex)
    }
    //
   
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


