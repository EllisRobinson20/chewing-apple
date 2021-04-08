
import SwiftUI
import CoreData



struct Workout{
   
    @FetchRequest(sortDescriptors: [])
    private var activities: FetchedResults<Activity>
    
    //get these from rep max and the selected target
    var targetKG: Float = 0
    var targetReps: Int = 0
    var totalSets: Int = 0
    var currentSpeed: String = ""
    var currentRepMax: Float = 0
    var intervalTimeMax: Int = 0
    var ImprovementIndex: Float = 0
//    var activityObj: Activity
    
    
//    var historyResult: FetchedResults<History> changed this to a local let in targetView

    
    //create storage and save it during these executions
    // func saveOnNextButtonPress
    
    mutating func targetView(target: String, activityName: String, textNode: String) -> String {
        var res: String = ""
        let historyResult = FilteredHistory(filterExercise: activityName, filterTarget: target).get()
        //get the activity
        for activity in activities {
            if activity.exerciseName == activityName {
                currentRepMax = activity.oneRepMax
                
                let targetObj = self.getTargetObj(name: target)
                let activityObj = activity
                
                    // do a fill in the blanks for the view
                    // each time this is called it will be for a different text node
                res = self.filter(forNode: textNode, fetchedResults: historyResult, currentActivity: activityObj, targetObj: targetObj!)
                
                
            }
        }
        return res
    }
    private mutating func getTargetObj(name: String) -> Target? {
        var targetObj: Target?
        for target in AppData().targets.targetsList {
            if target.targetName == name {
                targetObj = target
            }
        }
        return targetObj
    }
    private mutating func filter(forNode: String, fetchedResults: FetchedResults<History>, currentActivity: Activity, targetObj: Target) -> String {
        var result = ""
        switch forNode {
        case "kg":
            // if rep max bigger than index
            if currentActivity.oneRepMax > currentActivity.improvementIndex && currentActivity.improvementIndex > 0 {
                targetKG = currentActivity.oneRepMax * (Float(targetObj.oneRepMax[0])  / 100)
            }else
            if currentActivity.improvementIndex >= currentActivity.oneRepMax {
                targetKG = currentActivity.improvementIndex * (Float(targetObj.oneRepMax[0])  / 100)
            }
            result = String(targetKG)
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
        //get a median and the highest and the lowest - if the median is lower than 50% low to high
        //use median - if median is 50% or higher than the low to high range - then use highest figure
        // an even median would mean taking two middle numbers doing a+b/2
        //ALSO if no history then will have to assume the middle of the suggested target (filtered) weight
        case "setcount":
            totalSets = targetObj.targetSets[1]
            result = String(totalSets)
        case "speed":
            currentSpeed = targetObj.speed
            result = String(currentSpeed)
        case "interval":
            intervalTimeMax = targetObj.interval[1]
            result = String(intervalTimeMax)
        default:
            break
        }
        return result
    }
    
    private func getSuggestedRepCount(array: [Int]) -> Int {
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
    private func isEven(number: Int) -> Bool {
        if number % 2 == 0 {
            return true
        } else {
            return false
        }
    }
    
}
