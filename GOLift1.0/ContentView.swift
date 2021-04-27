
import SwiftUI
import CoreData

class Status: ObservableObject {
    @Published var currentExercise = 0
    @Published var activityName = ""
    //@Published var currentWeight: Float = 0.00
    @Published var currentTarget = ""
    @Published var targetIndex = 0
    @Published var targetKG: Float = 0.00
    @Published var currentSet: Int = 1
    
    @Published var repsAchieved: [Int] = [-1]
    @Published var weightAchieved: [Float] = [-1]
    
    func getCurrentExercise() -> String {
    activityName = helper.userSession[currentExercise]
        return activityName
    }
    
    
    ///App data
    func getTargetObj(index: Int) -> Target? {
        let targetObj: Target = AppData().targets.targetsList[index]
        print("TESTING2: \(targetObj)")
        return targetObj
    }
    func getCurrentReps(index: Int) -> Int {
        let target = getTargetObj(index: index)
        return (target?.repAmount.last) ?? 0 // .first for lower rep range .last for upper range suggestion
    }
    func getSetsRange(index: Int) -> [Int] {
        let target = getTargetObj(index: index)
        return target?.targetSets ?? [0,0]
    }
    
}
var status = Status()
struct ContentView: View {
    @State var currentExercise = status.currentExercise
    @State var currentSet = status.currentSet
    @State var setsRange = status.getSetsRange(index: status.targetIndex )
    
    @EnvironmentObject var viewRouter: ViewRouter
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "exerciseName == %@", status.getCurrentExercise()))
    private var currentActivity: FetchedResults<Activity>
    
    @FetchRequest(sortDescriptors: [])
    private var activities: FetchedResults<Activity>
    
    @FetchRequest(sortDescriptors: [
        NSSortDescriptor(keyPath: \History.date, ascending: false)
    ], predicate: NSCompoundPredicate(orPredicateWithSubpredicates: [
        NSPredicate(format: "exerciseName == %@", "\(status.getCurrentExercise())"),
        NSPredicate(format: "targetName == %@", "\(status.currentTarget)")
    ] ))
    private var lastHistory: FetchedResults<History>
    
    
    @StateObject var appData = AppData()
    
    let targets = ["Strength", "Power", "Volume", "Endurance" ]
    
    func roundToNearestQuarter(num : Float) -> Float {
        return round(num * 4.0)/4.0
    }

    /// Get exercise targets
    func getTargets() -> [String] {
        var arr = [" "]
            arr.removeAll()
        for target in appData.targets.targetsList {
            arr.append(target.targetName)
        }
        return arr
    }
//
    func saveDB() {
        do {
            try viewContext.save()
        } catch {
            let error = error as NSError
            fatalError("Unresolved Error: \(error)")
        }
    }
//
    func setRepMax(chosenExercise: String, maxKG: Float, repsCount: Int) {
        
        // calc the rep max on chosen activity
        // check activites db for previous entries
        //then compare them
            //if new on is less than old one as user if sure wants to update
            // if not update and give message "your rep max has gone up by X"
        //after this method call the view needs to update depending on which target was picked
        // so here there needs to be some state managment
        
            // !This for loop forcing the each activity USE new Filter
            
        
    
            let oneRepMax = maxKG / (1.0278 - 0.0278 * Float(repsCount) )
        if  currentActivity.first?.exerciseName == chosenExercise {
                print("Setting existing activity")
                for activity in activities {
                    print("Has Activities")
                if helper.userSession.contains( chosenExercise ) {
                activity.oneRepMax = oneRepMax
                    PersistenceController.shared.save()
                estTenRepKG(repMax: oneRepMax, activity: activity)
                }
                    print("new repmax:  \(activity.oneRepMax)")
                }
            } else {
                print("Creating new activity")
                if helper.userSession.contains( chosenExercise ) {
                    print("Connected to sessions.json...")
                    let newActivity = Activity(context: viewContext)
                    newActivity.exerciseName = chosenExercise
                newActivity.oneRepMax = oneRepMax
                    PersistenceController.shared.save()
                estTenRepKG(repMax: oneRepMax, activity: newActivity)
                }
            }
        //status.currentWeight = currentActivity.
        self.refreshUI()
    }
    
    func estTenRepKG(repMax: Float, activity: Activity) {
        let tenRepMax = repMax / 100 * 75
        activity.estTenRepsKG = tenRepMax
        self.saveDB()
        print(tenRepMax)
    }
    func validate(exercise: String) -> Bool {
        var res = true
        var activityList = [" "]
        
        activityList.removeAll()
        for activity in activities {
            if activity.exerciseName == exercise {
                activityList.append(exercise)
            }
        }
       
        if activityList.contains(exercise)  {
                res = true
            } else {
                res = false
            }
        return res
    }
    
    func refreshUI() {
        status.currentTarget = self.targets[currentTarget]
        // not sure if needed !!!! status.currentWeight = status.targetKG !!!!!
        // Add all the components that should refresh
        self.filter(forNode: "kg", lastHistory: lastHistory, currentActivity: currentActivity.first ?? Activity(context: viewContext),  target: self.targets[currentTarget])
        
        print("DEBUGG : \(currentWeight) AND ALSO : \(status.targetKG)")
    }
    
    //
    
    @State private var currentTarget = 0
    @State private var currentWeight =  status.targetKG
    @State private var targetRepetitions = status.getCurrentReps(index: status.targetIndex)//may need to change to currentTarget
    
    
    func explosiveRButton() -> String {
        if self.currentTarget == 0 {
            return "circle"
        }
        return "circle.fill"
    }
    func speedRButton() -> String {
        if self.currentTarget == 1 {
            return "circle"
        }
        return "circle.fill"
    }
    func strengthRButton() -> String {
        if self.currentTarget == 2 {
            return "circle"
        }
        return "circle.fill"
    }
    func powerRButton() -> String {
        if self.currentTarget == 3 {
            return "circle"
        }
        return "circle.fill"
    }
     
    func incrementPrecisely(incrementUp: Bool, incrementAmount: Float) {
        if incrementUp {
            currentWeight += incrementAmount
        }
        else if !incrementUp && currentWeight > 0 {
            currentWeight -= incrementAmount
        }
    }
    func increment(incrementUp: Bool, controlName: String) {
        if incrementUp && controlName == "weight" {
            currentWeight += 1
        }
        else if !incrementUp && currentWeight > 0 && controlName == "weight" {
            currentWeight -= 1
        }
        else if incrementUp && targetRepetitions < 30 && controlName == "reps" {
            targetRepetitions += 1
        }
        else if !incrementUp && targetRepetitions > 0 && controlName == "reps" {
            targetRepetitions -= 1
        }
    }
    func checkMatchingButton(ButtonToCheck: String) -> Bool {
        return true
    }
    
    func checkRepMaxIsSet() -> Bool {
        return currentActivity.first?.oneRepMax != nil
    }
    
    
    var body: some View {
        let targets = self.getTargets()
        Spacer()
        Text("\(checkRepMaxIsSet() ? "" : "\(helper.userSession[currentExercise])"  )")
            .onAppear() {
                self.refreshUI()
            }
            .onChange(of: status.targetKG) { newValue in
                self.refreshUI()
            }
            .foregroundColor(Color.red)
        Spacer()
        HStack{
            /// Back Button: Content View
            Button(action: {
                withAnimation  {viewRouter.currentPage = .page1}
            }) {
                Image(systemName: "chevron.left")
                Text("back")
                
            }.padding()
            Spacer()
        }
        VStack {
            /// Target selection
            Text("\(targets[currentTarget])")
                .font(.headline)
                .foregroundColor(.secondary)
            HStack{
                Button(action: {
                    currentTarget = 0
                    self.refreshUI()
                }
                ) {
                    Image(systemName: explosiveRButton())
                }
                Button(action: {
                    currentTarget = 1
                    self.refreshUI()
                }
                ) {
                    Image(systemName: speedRButton())
                }
                Button(action: {
                    currentTarget = 2
                    self.refreshUI()
                }
                ) {
                    Image(systemName: strengthRButton())
                }
                Button(action: {
                    currentTarget = 3
                    self.refreshUI()
                }
                ) {
                    Image(systemName: powerRButton())
                }
            }
            .buttonStyle(RadioButtonStyle())
            /// Current Exercise Label
            Text(self.validate(exercise: helper.userSession[currentExercise]) ? helper.userSession[currentExercise] : "Set your rep max!")
                .font(.title)
                .fontWeight(.bold)
                .padding()
                .foregroundColor(.secondary)
            .overlay(
             RoundedRectangle(cornerRadius: 15)
            .stroke(lineWidth: 2))
                .transition(AnyTransition.opacity.animation(.easeInOut(duration:1.0)))
            
            Spacer()
            // Weight to Lift
            HStack{
                Button(action: {
                   
                }) { Image(systemName: "chevron.backward")
                    
                    .onTapGesture(count: 2) {
                        incrementPrecisely(incrementUp: false, incrementAmount: 0.25)
                    }
                    .onTapGesture(count: 1) {
                        increment(incrementUp: false, controlName: "weight")
                }
                    .onLongPressGesture(minimumDuration:0.5) {
                        incrementPrecisely(incrementUp: false, incrementAmount: 10.00)
                    }
                    
                
                }
                Text("\(String(format: "%.2f", roundToNearestQuarter(num: currentWeight) ))")
                    .font(.largeTitle)
                    .bold()
            
                Text("kg")
                Button(action: {
                    
                }) { Image(systemName: "chevron.forward")
                    .onTapGesture(count: 2) {
                        incrementPrecisely(incrementUp: true, incrementAmount: 0.25)
                    }
                    .onTapGesture(count: 1) {
                        increment(incrementUp: true, controlName: "weight")
                    }
                    .onLongPressGesture(minimumDuration:0.5) {
                        incrementPrecisely(incrementUp: true, incrementAmount: 10.00)
                    }
                }
            }
            .scaleEffect(2)
            .padding(.vertical)
            // Repetitions
            HStack{
                Button(action: {increment(incrementUp: false, controlName: "reps")}) { Image(systemName: "chevron.backward")}
                Text("\(targetRepetitions)")
                    .font(.largeTitle)
                    .bold()
                Text("reps")
                Button(action: {increment(incrementUp: true, controlName: "reps")}) { Image(systemName: "chevron.forward")}
            }
            .padding(.bottom)
            Text("set \(currentSet) : \(setsRange[1])")
                .font(.largeTitle)
                .bold()
            Spacer()
            HStack {
                Button(action: {})
                {
                        Image(systemName: "questionmark.square.fill")
                            .resizable()
                            .scaledToFit()
                            .scaleEffect()
                }
                .buttonStyle(DemoButtonStyle())
                Button(action:{}){
                    
                    Image(systemName: "backward.end.alt")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(0.75)
                        .padding(.vertical)
                    //Text("Back")
                    
                }
                .buttonStyle(SecondaryButtonStyle())
                //.scaleEffect(0.7)
                Button(action:{
                    logRecord()
                    incrementSession()
                }){
                    
                    Image(systemName: isLastLap() ? "stop" : "forward.end.alt")
                        .resizable()
                        .scaledToFit()
                        .padding(.vertical, isLastLap() ? -2 : 17)
                        .animation(/*@START_MENU_TOKEN@*/.easeIn/*@END_MENU_TOKEN@*/)
                        .scaleEffect(isLastLap() ? 0.45 : 0.75)
                }
                .buttonStyle(SecondaryButtonStyle())
                Button(action: {self.setRepMax(chosenExercise: helper.userSession[currentExercise], maxKG:  Float(currentWeight), repsCount: self.targetRepetitions )})
                {
                    Text("REP\nMAX")
                        .multilineTextAlignment(.center)
                        .font(.title3)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .scaleEffect(0.7)
            Spacer()
        }.onAppear() {
            setsRange = status.getSetsRange(index: currentTarget )
            //clearRecords()
        }
        
    }
    
    //
    //
    //
    
    
    @State var currentRepMax = 0
    @State var s = ""
    @State var currentImprovementIndex = 0
    
    
//    var body: some View {
//        Text(String(s))
//            .onAppear() {
//
//            }
//
//        //Text(String(fetchRequest.wrappedValue.first?.exerciseName ?? "nill"))
//    }
    
   
    
     func filter(forNode: String, lastHistory: FetchedResults<History>, currentActivity: Activity, target: String){
        print("filter called")
        let targetObj = getTargetObj(name: target)
        //Set the current sets range on filter action
        setsRange = status.getSetsRange(index: currentTarget )
        //to class level
       var targetReps: Int = 0 // to class level
       var result = ""
        //
        //
        //
        if lastHistory.isEmpty {
            // set and get from activity (see notes)
            //num = historyResult.wrappedValue.first?.repsAchieved as! Int
            print("Activity name in DV.init() \(String(describing: currentActivity.exerciseName))")
            if currentActivity.exerciseName != nil {
                // Value for the view state
                // Keep all the calculations local
                currentRepMax = Int(currentActivity.oneRepMax )
                print("\(currentRepMax)")
                // now update the improvement index with setActivityIndex
                //!! Setting activity may need to be done in main ui eg set the helper then do a save context on the button presses
                setActivityIndex(index: 0, activity: currentActivity)
               
            }
            
            
            //
            // Now filter the blanks depending on the values ...
            // First get the static Target from targets.json
            
                    //let targetObj = getTargetObj(name: target)
            
            // Then get activity object with getActivityObject
                //let activityObject = getActivityObject(exerciseName: activityName)
            // Dont forget to keep th state will with helper for DB to be able to read on rtn from the filter
            
            //Filter method is next NOTE: need variables that are in class level scope rather than local
            
        }
        
        //
        //
        //
        
        
        
        
        
        
        
        
       switch forNode {
       case "kg":
           // if rep max bigger than index
        //Test for call from UI
        print("kg called")
        
        //This code should not call the improvement index to make a comparison
        // It should be the history, though we are saying here that history is nill so will never
        // run ...
//           if Int16(currentActivity.oneRepMax) > currentActivity.improvementIndex && currentActivity.improvementIndex > 0 {
//            targetKG = currentActivity.oneRepMax * (Float(targetObj?.oneRepMax[0] ?? 0)  / 100)
//            print("1.target kg set to : \(targetKG)")
//           }else
//           if currentActivity.improvementIndex >= Int16(currentActivity.oneRepMax) {
//            targetKG = Float(currentActivity.improvementIndex) * (Float(targetObj?.oneRepMax[0] ?? 0)  / 100)
//            print("2.target kg set to : \(targetKG)")
//           }else
        
           if currentActivity.oneRepMax >= 0 {
            status.targetKG = currentActivity.oneRepMax * (Float(targetObj?.oneRepMax[0] ?? 0)  / 100)
            currentWeight = currentActivity.oneRepMax * (Float(targetObj?.oneRepMax[0] ?? 0)  / 100)
            targetRepetitions = status.getCurrentReps(index: currentTarget)
            
           }
        result = String(status.targetKG)
        
           break
       //if index bigger than rep max
       case "rep":
           // will need to check the history, newest entry of reps achieved
        if  !lastHistory.isEmpty {
               print("Workout.swift: result not nil")
            let nsObj = lastHistory.first?.repsAchieved
               let arr1 = NSArray(objects: nsObj ?? NSArray())
               let objCArray = NSMutableArray(array: arr1)
               let swiftArray: [Int] = objCArray.compactMap({ $0 as? Int })
               targetReps = getSuggestedRepCount(array: swiftArray)
               print("The array to print: \(swiftArray)")
               // need to get that rep counter and from that transformable
               
           } else {
               print("Workout.swift: result is nil")
            targetReps = targetObj?.targetSets[0] ?? 0
           }
           result = String(targetReps)
           break
       //get a median and the highest and the lowest - if the median is lower than 50% low to high
       //use median - if median is 50% or higher than the low to high range - then use highest figure
       // an even median would mean taking two middle numbers doing a+b/2
       //ALSO if no history then will have to assume the middle of the suggested target (filtered) weight
       case "setcount":
//to class level with total sales current speed interval timemax
        let totalSets = targetObj?.targetSets[1]
        result = String(totalSets ?? 0)
           break
       case "speed":
        let currentSpeed = targetObj?.speed
        result = String(currentSpeed ?? "Nill Value")
           break
       case "interval":
        let intervalTimeMax = targetObj?.interval[1]
        result = String(intervalTimeMax ?? 0)
           break
       default:
           break
       }
       //return result
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
    private func getTargetObj(name: String) -> Target? {
        var targetObj: Target?
        for target in AppData().targets.targetsList {
            if target.targetName == name {
                targetObj = target
            }
        }
        return targetObj
    }
    
    /// History
    func newHistoryRecord() -> History {
        let newRecord = History(context: viewContext)
        newRecord.date = Date()
        newRecord.exerciseName = helper.userSession[currentExercise]
        newRecord.targetName = targets[currentTarget]
        return newRecord
    }
    func clearRecords() {
        print("clearing all records")
        status.repsAchieved.removeAll()//clear arrays
        status.weightAchieved.removeAll()
        status.repsAchieved.append(-1)
        status.weightAchieved.append(-1)
        print("\(status.weightAchieved)")
    }
    func recordIsCleared() -> Bool {
        print(status.repsAchieved.first == -1 && status.weightAchieved.first == -1.0)
        print(status.repsAchieved.first)
        print(status.weightAchieved.first)
        return status.repsAchieved.first == -1 && status.weightAchieved.first == -1.0
    }

    func logRecord() {
        
        
        if (recordIsCleared()) {
            print("new record required ... initialising arrays")
            status.repsAchieved.removeAll()
            status.weightAchieved.removeAll()
            print("... \(status.weightAchieved)")
            print("CV.logRecord: Creating new History record")
            // Add a rep count to an array first to pass in here
            status.repsAchieved.append(targetRepetitions)
            status.weightAchieved.append(currentWeight)
            print("... \(status.weightAchieved)")
            let newRecord = newHistoryRecord()
            newRecord.repsAchieved = NSMutableArray(array: status.repsAchieved)
            newRecord.weightsAchieved = NSMutableArray(array: status.weightAchieved)
            saveDB()
            // Increment called from the button also
            
        } else {
            updateRepsRecord()
            // same proccess for the weight achieved
            updateWeightsRecord()
            
        }
        
        // now when the newHostory date is full - get last history and update that
        //make sure the arrays do not fill more than the number of sets and weights achieved
    }
    func incrementSession() {
        //here will test the state of the sets and exercises before deciding what to increment
        if (stillHasExercises() && stillHasSets()) { // and current reps less than targetreps[1]
            // then increment sets only
            print("Incrementer: current set + 1")
            currentSet += 1
        } else
        if (stillHasExercises() && !stillHasSets()) {
            print("Incrementer: To the next exercise ... ")
            // current set back to 1
            currentSet = 1
            // currentExercise +1
            currentExercise += 1
            //dont forget to make the testers -1 again when go to next exercise and on game finish
            clearRecords()
        } else
        if (!stillHasExercises() && stillHasSets()) {
            print("Incrementer: Incrementing last exercise - current set + 1")
            //increment only sets
            currentSet += 1
        } else
        if (!stillHasExercises() && !stillHasSets()) {
            print("Incrementer: no more exercises or sets")
            //end of session
            // reset currentSet to 1
            currentSet = 1
            // reset currentExercise to1
            currentExercise = 1
            clearRecords()
            viewRouter.currentPage = .page1
        }
        
    }
    func stillHasExercises() -> Bool {
        print("\(currentExercise+1) + \(helper.userSession.count)")
        print((currentExercise+1) < helper.userSession.count)
        return (currentExercise+1) < helper.userSession.count
    }
    func stillHasSets() -> Bool {
        print("\(status.repsAchieved.count) + \(setsRange[1])")
        print(status.repsAchieved.count < setsRange[1])
        return status.repsAchieved.count < setsRange[1]
    }
    func isLastLap()  -> Bool {
        // last lap if no exercises and current sets is one less than total sets
        print("Testing for last lap: \(!stillHasExercises() ) + \((status.repsAchieved.count+1 == setsRange[1]))")
        let isLast = !stillHasExercises() && (status.repsAchieved.count+1 == setsRange[1])
        return isLast
    }
    
    func updateRepsRecord() {
        if (!lastHistory.isEmpty) {
        print("updating record: \(String(describing: lastHistory.first?.date)) \(lastHistory.first?.exerciseName)")
        print("current array values for Reps: \(String(describing: lastHistory.first?.repsAchieved))")
        
        var swiftArray: [Int] = lastHistory.first?.repsAchieved as! [Int]
        print("swiftArray Pre Values: \(swiftArray)")
        swiftArray.append(targetRepetitions)
        //swiftArray.append(targetRepetitions)
        print("swift array post values: \(swiftArray)")
        //now save the data to the same record
        lastHistory.first?.repsAchieved = NSMutableArray(array: swiftArray)
        saveDB()
        print("values after save for Reps: \(String(describing: lastHistory.first?.repsAchieved))")
            //add to the array in status or will not affect ui when changinh sets values
            status.repsAchieved.append(targetRepetitions)
    }
    }
    func updateWeightsRecord() {
        if (!lastHistory.isEmpty) {
        print("updating record: \(String(describing: lastHistory.first?.date)) \(lastHistory.first?.exerciseName)")
        print("current array values for Weight: \(String(describing: lastHistory.first?.weightsAchieved))")
        var swiftArray: [Float] = lastHistory.first?.weightsAchieved as! [Float]
        print("swift array pre values: \(swiftArray)")
        swiftArray.append(currentWeight)
        print("swift array post values: \(swiftArray)")
        //now save the data to the same record
        lastHistory.first?.weightsAchieved = NSMutableArray(array: swiftArray)
        saveDB()
        print("values after save for Weight: \(String(describing: lastHistory.first?.weightsAchieved))")
            //add to the array in status or will not affect ui when changinh sets values
            status.weightAchieved.append(currentWeight)
    }
    }
    
    
    
    
}

