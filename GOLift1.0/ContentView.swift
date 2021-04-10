
import SwiftUI
import CoreData


struct ContentView: View {
    @State var currentExercise = 1
    @EnvironmentObject var viewRouter: ViewRouter
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(sortDescriptors: [])
    private var activities: FetchedResults<Activity>
    
    
    @StateObject var appData = AppData()

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
       
//        let targets = self.getTargets()
//        let activityResult = FilteredActivity(filterExercise: helper.userSession[currentExercise], filterTarget: targets[currentTarget])
//            .get()
        
        // calc the rep max on chosen activity
        // check activites db for previous entries
        //then compare them
            //if new on is less than old one as user if sure wants to update
            // if not update and give message "your rep max has gone up by X"
        //after this method call the view needs to update depending on which target was picked
        // so here there needs to be some state managment
        var activityList = [" "]
        activityList.removeAll()
        for activity in activities {
            // !This for loop forcing the each activity USE new Filter
            if activity.exerciseName == chosenExercise {
                activityList.append(chosenExercise)
            }
        }
        
        
            let oneRepMax = maxKG / (1.0278 - 0.0278 * Float(repsCount) )
        if  activityList.contains(chosenExercise) {
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
    
    //
    
    @State private var currentTarget = 0
    @State private var currentWeight = 0
    @State private var targetRepetitions = 0
    
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
       
    func increment(incrementUp: Bool, controlName: String) {
        if incrementUp && controlName == "weight" {
            currentWeight += 1
        }
        else if !incrementUp && currentWeight > 0 && controlName == "weight" {
            currentWeight -= 1
        }
        else if incrementUp && targetRepetitions < 16 && controlName == "reps" {
            targetRepetitions += 1
        }
        else if !incrementUp && targetRepetitions > 0 && controlName == "reps" {
            targetRepetitions -= 1
        }
    }
    func checkMatchingButton(ButtonToCheck: String) -> Bool {
        return true
    }
    
    
    func getCurrentWeight() -> String {
        let targets = self.getTargets()
        var workout = Workout()
        // Modify the current target first using workout.targetView()
        let weightToLift = workout.targetView(target: targets[currentTarget], activityName: helper.userSession[currentExercise], textNode: "kg")
        if !weightToLift.isEmpty {
            currentWeight = Int(weightToLift)!
        }
        return String(currentWeight)
    }
    
    var body: some View {
        
        let targets = self.getTargets()
//        DynamicText(filterKey: "exerciseName", filterValue: helper.userSession[currentExercise]) { (activity: Activity) in
//            Text("\(activity.exerciseName ?? "")\(activity.oneRepMax)")
//        }
        DynamicText(target: targets[currentTarget], activityName: "standing squat", textNode: "kg")
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
                }
                ) {
                    Image(systemName: explosiveRButton())
                }
                Button(action: {
                    currentTarget = 1
                }
                ) {
                    Image(systemName: speedRButton())
                }
                Button(action: {
                    currentTarget = 2
                }
                ) {
                    Image(systemName: strengthRButton())
                }
                Button(action: {
                    currentTarget = 3
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
                Button(action: {increment(incrementUp: false, controlName: "weight")}) { Image(systemName: "chevron.backward") }
                Text("\(self.currentWeight)")
                    .font(.largeTitle)
                    .bold()
            
                Text("kg")
                Button(action: {increment(incrementUp: true, controlName: "weight")}) { Image(systemName: "chevron.forward")}
            }
            .scaleEffect(2)
            .padding(.vertical)
            // Repetitions
            HStack{
                Button(action: {increment(incrementUp: false, controlName: "reps")}) { Image(systemName: "chevron.backward")}
                Text("\(self.targetRepetitions)")
                    .font(.largeTitle)
                    .bold()
                Text("reps")
                Button(action: {increment(incrementUp: true, controlName: "reps")}) { Image(systemName: "chevron.forward")}
            }
            .padding(.bottom)
            Text("set 1 : 3")
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
                Button(action:{}){
                    
                    Image(systemName: "forward.end.alt")
                        .resizable()
                        .scaledToFit()
                        .padding(.vertical)
                        .scaleEffect(0.75)
                    //Text(" Next")
                    
                }
                .buttonStyle(SecondaryButtonStyle())
                Button(action: {self.setRepMax(chosenExercise: helper.userSession[currentExercise], maxKG:  Float(self.currentWeight), repsCount: self.targetRepetitions )})
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
            
        }
        
    }
}


