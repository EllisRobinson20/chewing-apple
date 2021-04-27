
import SwiftUI
import SceneKit
import SpriteKit

import CoreData
var appDataGlobal = AppData()
var helper = Helper()
struct BodyMapView: View {
    
    
    @EnvironmentObject var viewRouter: ViewRouter
    
    // UI selection helper
    @ObservedObject var localHelper = helper
    // options modal
    @State private var isPresented = false
    // app data
    @EnvironmentObject var appData: AppData
    //user Data
    @FetchRequest(sortDescriptors: [])
    private var exerciseDB: FetchedResults<ExerciseState>
    @FetchRequest(sortDescriptors: [
        NSSortDescriptor(keyPath: \History.date, ascending: false)
    ])
    private var historyDB: FetchedResults<History>
    
    /// Create body map
    func bodyMap() -> SCNScene {
        
        //Low Poly body to decrease render time
        let scene = SCNScene(named: "model.scnassets/BodyLOWPOLY.scn")
        
        let subScene1 = SCNScene(named: "model.scnassets/BodyMalePectoral.scn")
        let subScene2 = SCNScene(named: "model.scnassets/BodyMaleBiceps.scn")
        let subScene3 = SCNScene(named: "model.scnassets/BodyMaleAbdominals.scn")
        let subScene4 = SCNScene(named: "model.scnassets/BodyMaleQuads.scn")
        
        let body = (scene?.rootNode.childNode(withName: "body_low", recursively: true))!
        let pectoral = (subScene1?.rootNode.childNode(withName: "body_high_003", recursively: true))!
        let biceps = (subScene2?.rootNode.childNode(withName: "body_high_004", recursively: true))!
        let abs = (subScene3?.rootNode.childNode(withName: "body_high_002", recursively: true))!
        let quads = (subScene4?.rootNode.childNode(withName: "body_high_001", recursively: true))!
        //raise the profile of the muscles laying over the frame
        pectoral.position.z = 1.0
        biceps.position.z = 1.0
        abs.position.z = 1.0
        quads.position.z = 1.0
        //add a color with material instead
        let bodyMaterial = SCNMaterial()
        bodyMaterial.diffuse.contents = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        body.geometry?.materials = [bodyMaterial]
        scene?.rootNode.addChildNode(pectoral)
        scene?.rootNode.addChildNode(biceps)
        scene?.rootNode.addChildNode(abs)
        scene?.rootNode.addChildNode(quads)
        scene?.rootNode.addChildNode(body)
        return scene!
    }
    /// Main View
    var body: some View {
        let scene = bodyMap()
       /// Body Map View
        NavigationView {
        VStack{
            SceneView(scene: scene, options: [ ])
                .frame(width: UIScreen.main.bounds.width , height: UIScreen.main.bounds.height * 0.5)
                .onAppear() {
                    let materialB = SCNMaterial()
                    materialB.diffuse.contents = paintBodyPart(bodypartname: "Biceps")
                    let biceps = scene.rootNode.childNode(withName: "body_high_004", recursively: true)
                    biceps?.geometry?.replaceMaterial(at: 0, with: materialB)
                    let materialP = SCNMaterial()
                    materialP.diffuse.contents = paintBodyPart(bodypartname: "Pectorals")
                    let pectorals = scene.rootNode.childNode(withName: "body_high_003", recursively: true)
                    pectorals?.geometry?.replaceMaterial(at: 0, with: materialP)
                    let materialA = SCNMaterial()
                    materialA.diffuse.contents = paintBodyPart(bodypartname: "Abdominals")
                    let abdominals = scene.rootNode.childNode(withName: "body_high_002", recursively: true)
                    abdominals?.geometry?.replaceMaterial(at: 0, with: materialA)
                    let materialQ = SCNMaterial()
                    materialQ.diffuse.contents = paintBodyPart(bodypartname: "Quadriceps")
                    let quadriceps = scene.rootNode.childNode(withName: "body_high_001", recursively: true)
                    quadriceps?.geometry?.replaceMaterial(at: 0, with: materialQ)
                }
            VStack
            {
                Text(localHelper.muscleName)
                        .font(.system(size: 45, weight: .bold))
                    .padding(.bottom)
                    .multilineTextAlignment(.center)
                HStack
                {
                    
                    Spacer()
                    /// Start Session Button
                    Button(localHelper.startButtonName) {
                        startSession()
                        withAnimation{
                            viewRouter.currentPage = .page2
                        }
                    }
                    
                   
                    
                    Spacer()
                    /// Options Button
                    Button(localHelper.optionsButtonName) {
                                isPresented.toggle()
                    }
                    .buttonStyle(OptionsButtonStyle())
                    .fullScreenCover(isPresented: $isPresented, content: FullScreenModalView.init)
                    
                    .shadow(color: .black, radius: 2, x: 0.0, y: 0.0)
                    Spacer()
                }
            }
            Spacer(minLength: 0)
        }
        }
        .onAppear() {
            setColor()
        }
    }
    func checkStateMainView(name: String) -> Bool {
        var bool: Bool?
        
        for exercise in exerciseDB {
            if name == exercise.name {
                bool = exercise.isAdded
            }
        }
        return bool!
    }
    //o think here in this method somthing is not working right as the array still appends two names
    // what may be the case is that these mathods such as check state main view
    // are not calling save so below ultimately the array gets wiped and replaced with the same default array each time
    //this means that there is no need to do the manual work with removing items from array
    // the view contaext just needs to be saved. wonder if woul do this on navigate away from the popup? or each time the check mark is changed
    func startSession() {
        helper.clearSession()
        for exercise in appData.exercises.exerciseList {
            if exercise.resistanceIndex[helper.currentSession().muscleIndexPosition] >= 3
            && checkStateMainView(name: exercise.name)
            {
                helper.userSession.append(exercise.name)
                print("added \(exercise.name)")
            }
        }
        print(helper.userSession)
    }
    
    
    func setColor() {
        let now = Date()
        var latestRecords = [String:Date?]()
        
        // for i in muslce names
        // for h in history
        // for i in appdata.exercises
        // if h.name
        
        //..get neareast history where history.exname == app getMatchingRecordName(history.exname) -> String {loop the appdata()exercises.json}
        // for each muscle name - get the most recent record
        
       // while (latestRecords.count <= historyDB.count && historyDB.first?.exerciseName != nil) {
            var counters = [0,0,0,0]
            var obj : Exercise
            for h in historyDB {
                print("Running")
                obj = getMatchingJSONObject(recordName: h.exerciseName!)
                print("obj resistance index: \(obj.resistanceIndex) + name: \(obj.name)")
                print("checking array size: \(obj.resistanceIndex.count) + last array value: \(obj.resistanceIndex.last)")
                if (obj.resistanceIndex.first! > obj.resistanceIndex[1] &&
                        obj.resistanceIndex.first! > obj.resistanceIndex[2] &&
                        obj.resistanceIndex.first! > obj.resistanceIndex[3] &&
                        counters[0] != -1
                ) {
                    latestRecords.updateValue(h.date, forKey: "Biceps")
                    counters.insert(-1, at: 0)
                    print("attempting to add \(String(describing: h.date))")
                } else
                if (obj.resistanceIndex[1] > obj.resistanceIndex[0] &&
                    obj.resistanceIndex[1] > obj.resistanceIndex[2] &&
                    obj.resistanceIndex[1] > obj.resistanceIndex[3] &&
                        counters[1] != -1
                ) {
                    latestRecords.updateValue(h.date, forKey: "Pectorals")
                    counters.insert(-1, at: 1)
                    print("attempting to add \(String(describing: h.date))")
                }else
                if (obj.resistanceIndex[2] > obj.resistanceIndex[0] &&
                    obj.resistanceIndex[2] > obj.resistanceIndex[1] &&
                    obj.resistanceIndex[2] > obj.resistanceIndex[3] &&
                        counters[2] != -1
                ) {
                    latestRecords.updateValue(h.date, forKey: "Abdominals")
                    counters.insert(-1, at: 2)
                    print("attempting to add \(String(describing: h.date))")
                }else
                if (obj.resistanceIndex[3] > obj.resistanceIndex[0] &&
                    obj.resistanceIndex[3] > obj.resistanceIndex[1] &&
                    obj.resistanceIndex[3] > obj.resistanceIndex[2] &&
                        counters[3] != -1
                ) {
                    latestRecords.updateValue(h.date, forKey: "Quadriceps")
                    counters.insert(-1, at: 3)
                    print("attempting to add \(String(describing: h.date))")
                }
            }
        
        
        var times = [Double]()
        for record in latestRecords {
            //if record.
            var time = getElapsedTime(fromDate: now, toDate: record.value!)
            print("testing for time \(getElapsedTime(fromDate: now, toDate: record.value!)) key \(record.key)")
            time *= -1 // Negative time value
            time /= 3600 // seconds to hours
            times.append(time)
            helper.muscleDictionary.updateValue(time, forKey: record.key)
            
        }
        print(times)
        // time elapsed between array 0 and now
        
        // time elapsed between array 1 and now
        // time elapsed between array 2 and now
        // time elapsed between array 3 and now
        
        // store the times elsaped somehow (say in helper) and check time
        
        //elspsed against some enum or dictionary for the right color
    }
    func getMatchingJSONObject(recordName: String) -> Exercise {
        var ex: [Exercise] = appData.exercises.exerciseList
        for exercise in appData.exercises.exerciseList {
            if recordName == exercise.name {
                ex.removeAll()
                ex.append(exercise)
            }
        }
        return ex.first!
    }
    
    func getElapsedTime(fromDate: Date, toDate: Date) -> TimeInterval {
        return toDate.timeIntervalSince(fromDate)
    }


func paintBodyPart(bodypartname:String) -> UIColor {
    let timeElapsed = helper.muscleDictionary[bodypartname]
    var red = CGFloat(0.0)
    var green = CGFloat(0.0)
    var blue = CGFloat(0.0)
    var alpha = CGFloat(0.0)
    print("print body part called. Time elapsed value: \(String(describing: timeElapsed))")
    // if less than 24 hours
    if (timeElapsed ?? 145 < 24) {
        //red
        print("Value is Red")
        
        //var newColor = UIColor(red: 0.88, green: 0.02, blue: 0.00, alpha: 1.00)
        red = 0.88
        green = 0.02
        blue = 0.00
        alpha = 1.00
        
    } else // if more than 24 hours but less than 48 hours
    if (timeElapsed ?? 145 > 24 && timeElapsed ?? 145 < 48) {
        //opaque 50% red
        print("Value is Red")
        //color = UIColor(red: 0.88, green: 0.02, blue: 0.00, alpha: 0.50)
        red = 0.88
        green = 0.02
        blue = 0.00
        alpha = 0.50
        
    } else // if more than 48 but less than 72
    if (timeElapsed ?? 145 > 48 && timeElapsed ?? 145 < 72) {
        // amber / orange
        print("Value is Orange")
        //color = UIColor(red: 1.00, green: 0.78, blue: 0.00, alpha: 1.00)
        red = 1.00
        green = 0.78
        blue = 0.00
        alpha = 1.00
        
    } else // if more than 72 but less than 144
    if (timeElapsed ?? 145 > 72 && timeElapsed ?? 145 < 144) {
        // green
        print("Value is Green")
        //color = UIColor(red: 0.28, green: 0.89, blue: 0.19, alpha: 1.00)
        red = 0.28
        green = 0.89
        blue = 0.19
        alpha = 1.00
        
        
    } else // if more than 144
    if (timeElapsed ?? 0 > 144) {
       //default colour
        print("Value is Gray")
        //color = UIColor(red: 0.50, green: 0.50, blue: 0.50, alpha: 1.00)
        red = 0.50
        green = 0.50
        blue = 0.50
        alpha = 1.00
        
    } else
    if (timeElapsed == nil) {
        print("Value is Default Grey")
        red = 0.50
        green = 0.50
        blue = 0.50
        alpha = 1.00
    }

    print("Actual Value: \(red) : \(green) : \(blue)")
    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    
    
}
}
struct BodyMapView_Previews: PreviewProvider {
    static var previews: some View {
        BodyMapView()
    }
}

struct SceneView: UIViewRepresentable {
    var scene: SCNScene
    var options: [Any]
    
    var view = SCNView()
    
    func makeUIView(context: Context) -> SCNView {
        // Instantiate the SCNView and setup the scene
        view.scene = scene
        view.pointOfView = scene.rootNode.childNode(withName: "camera", recursively: true)
        view.allowsCameraControl = true
        // Add gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        return view
    }
    
    func updateUIView(_ view: SCNView, context: Context) {
        //Code aims to overlay a HUD ...
//        let Lscene = SKScene()
//        Lscene.backgroundColor = UIColor(displayP3Red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
//        view.overlaySKScene = Lscene
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(view)
    }
    /// Co-ordinator
    class Coordinator: NSObject {
        private let view: SCNView
        init(_ view: SCNView) {
            self.view = view
            
            super.init()
        }
        /// On tap handler
        @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
            // check what nodes are tapped
            let p = gestureRecognize.location(in: view)
            let hitResults = view.hitTest(p, options: [:])
            
            
            // check that we clicked on at least one object
            if hitResults.count > 0 {
                
                // retrieved the first clicked object
                let result = hitResults[0]
                if result.node.name != "body_low" {
                // get material for selected geometry element
                let material = result.node.geometry!.materials[(result.geometryIndex)]
                // highlight it
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                // on completion - unhighlight
                SCNTransaction.completionBlock = {
                    SCNTransaction.begin()
                    SCNTransaction.animationDuration = 0.5
                    material.emission.contents = UIColor.black
                    SCNTransaction.commit()
                }
                material.emission.contents = UIColor.blue
            
                SCNTransaction.commit()
                
                //change the state of which body part pressed
                
                if result.node.name == "body_high_003" {
                    helper.muscleName =
                        "Pectorals"
                } else
                if result.node.name == "body_high_004" {
                    helper.muscleName =
                        "Biceps"
                }
                else
                if result.node.name == "body_high_002" {
                    helper.muscleName =
                        "Abdominals"
                }
                else
                if result.node.name == "body_high_001" {
                    helper.muscleName =
                        "Quadriceps"
                }
                    helper.activateView()
                }
            }
        }
    }
}
/// Helper class
class Helper: ObservableObject {
    // app data
    @EnvironmentObject var appData: AppData
    @Published var muscleName: String = "Choose a Workout"
    @Published var optionsButtonName: String = ""
    @Published var optionsActive: Bool = false
    @Published var buttonBorders: CGFloat = 0
    @Published var buttonOpacity: Double = 0.0
    @Published var startButtonName: String = ""
    // User Data
    @FetchRequest(sortDescriptors: [])
    private var exerciseDB: FetchedResults<ExerciseState>
    @Published var userSession = ["Create a session first"]
    @Published var muscleDictionary: Dictionary<String, Double> = [:]
    
    func clearSession() {
        userSession.removeAll()
    }
 
    func activateView() {
        helper.optionsButtonName = "Options"
        helper.startButtonName = "START"
        helper.buttonBorders = 2
        helper.buttonOpacity = 0.8
        //helper.exerciseDictionary.removeAll()
    }
    
    func currentSession() -> Session {
        var selectedSession = appDataGlobal.sessions.sessions[0]
        for i in 0..<appDataGlobal.sessions.sessions.count {
            
            if helper.muscleName == appDataGlobal.sessions.sessions[i].muscleName {
                selectedSession = appDataGlobal.sessions.sessions[i]
            }
        }
    return selectedSession
    }
    func checkState(name: String) -> Bool {
        var bool: Bool?
        
        for exercise in exerciseDB {
            if name == exercise.name {
                bool = exercise.isAdded
            }
        }
        return bool!
    }
    
    
    
    
}
//Handles options view
struct FullScreenModalView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    // app data
    @EnvironmentObject var appData: AppData
    //dropdown
    @State private var showDropdown = false
    @State var localHelper = helper
    @State var allExerciseStates = [:]
    @FetchRequest(sortDescriptors: [])
    private var activitiesDB: FetchedResults<Activity>
    @FetchRequest(sortDescriptors: [])
    private var exerciseDB: FetchedResults<ExerciseState>
    @FetchRequest(sortDescriptors: [
        NSSortDescriptor(keyPath: \History.date, ascending: false)
    ])
    private var historyDB: FetchedResults<History>
    
    
    func changeState(name: String) {
        for exercise in exerciseDB {
            if name == exercise.name {
                exercise.isAdded = !exercise.isAdded
                PersistenceController.shared.save()
            }
        }
    }
    /// Main Body
    var body: some View {
        NavigationView {
            /// List of Related Exercises
            List {
                ForEach(appDataGlobal.exercises.exerciseList) { exercise in
                    if exercise.resistanceIndex[helper.currentSession().muscleIndexPosition] >= 3 {
                        VStack {///Expandable dropdown area
                            HStack {///List Row
                                ZStack {
                                    Circle()
                                        .fill(Color.orange)
                                } /// Colour Indicator
                                .frame(maxWidth:18, alignment: .leading)
                                .padding(.vertical)
                                /// Scrollable text area
                                ScrollView(.horizontal, showsIndicators: true) {
                                    HStack {
                                        Text(exercise.name)
                                            .font(.headline)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.vertical)
                                    }
                                }
                                    ZStack{
                                        ProgressView(value: 0.95)
                                        .progressViewStyle(ProgressViewStyleTop())
                                    ProgressView(value: 0.65)
                                        .progressViewStyle(ProgressViewStyleBottom())
                                    }.frame(maxWidth:100, alignment: .leading) /// Performance to Target Ratio
                                Image(systemName: self.checkStateFSModal(name: exercise.name) ? "checkmark.square" : "square")
                                    .onTapGesture(count:1) {
                                        self.changeState(name: exercise.name)
                                    }
                            }
                            if showDropdown {
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(Color.green)
                                    }
                                    .frame(maxWidth:18, alignment: .leading)
                                    .padding(.vertical)
                                    VStack(alignment: .leading) {
                                        Text("One Rep Max: \(roundToNearestQuarter(num: getRepMax(exerciseName: exercise.name)))") 
                                    }
                                    Spacer()
                                }
                                HStack {
                                    ZStack {
                                        Circle()
                                            .fill(Color.green)
                                    }
                                    .frame(maxWidth:18, alignment: .leading)
                                    .padding(.vertical)
                                    VStack(alignment: .leading) {
                                        // Text("\(getLastDate(exerciseName: exercise.name))")
                                         Text("\(hasHistory(exerciseName: exercise.name) ? "Last Exercised: \(getLastDate(exerciseName: exercise.name))" : "")")
                                       
                                    }
                                    Spacer()
                                }
                                
                                
                                
                                        }
                        }
                    }
                    
                }
            }
            .navigationTitle(helper.muscleName)
            .navigationBarItems(leading: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            }, trailing: Toggle("", isOn: $showDropdown)
                                    .toggleStyle(ChevronToggleStyle())
                                    .labelsHidden() )
            .onAppear() {/*chosenExercisesDictionary = createMutableForExercise()*/}
        }
    }
    func roundToNearestQuarter(num : Float) -> Float {
        return round(num * 4.0)/4.0
    }
    
    func getRepMax(exerciseName: String) -> Float {
        var result = Float()
        for activity in activitiesDB {
            if (activity.exerciseName == exerciseName) {
                result = activity.oneRepMax
            }
        }
        return result
    }
    func getLastDate(exerciseName: String) -> String {
        var date = Date()
        for history in historyDB {
            if (history.exerciseName == exerciseName) {
                date = history.date ?? Date(timeIntervalSince1970: 0)
            }
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
         
        
         
        // US English Locale (en_UK)
        dateFormatter.locale = Locale(identifier: "en_UK")
        let dateAsString = dateFormatter.string(from: date)
        
        return dateAsString
    }
    func hasHistory(exerciseName: String) -> Bool {
        var bool = false
        for history in historyDB {
            if (history.exerciseName == exerciseName) {
                bool = true
            }
        }
        return bool
    }
    
    func addExercise(name: String) {
       //to array
    }
    func removeExercise(name: String) {
        //to array
    }
    func checkStateFSModal(name: String) -> Bool {
        var bool: Bool?
        for exercise in exerciseDB {
            if name == exercise.name {
                bool = exercise.isAdded
            }
        }
        return bool!
    }
    
}










