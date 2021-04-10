
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
        //add color
        pectoral.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        biceps.geometry?.firstMaterial?.diffuse.contents = UIColor.orange
        abs.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        quads.geometry?.firstMaterial?.diffuse.contents = UIColor.red
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
            }
        }
        print(helper.userSession)
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
        view.allowsCameraControl = false
        
        
        // Add gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handleTap(_:)))
        view.addGestureRecognizer(tapGesture)
        
        return view
    }
    
    func updateUIView(_ view: SCNView, context: Context) {
        //
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
                material.emission.contents = UIColor.gray
            
                SCNTransaction.commit()
                
                //change the state of which body part pressed
                
                if result.node.name == "body_high_003" {
                    helper.muscleName = "Pectorals"
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
                                            Text("Hello World!")
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










