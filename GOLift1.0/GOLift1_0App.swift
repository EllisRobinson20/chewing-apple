

import SwiftUI
@main
struct GOLift1_0App: App {
    let persistenceController = PersistenceController.shared
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var viewRouter = ViewRouter()
    @StateObject var appData = AppData()
    var isReset = false

    var exerciseState = FilteredExerciseState().get()
    var allActivities = AllActivity().get()
    //
    func addExerciseStates() {
        print("New Items To Be Created \\/")
        for i in 0..<appData.exercises.exerciseList.count {
            print(" \(appData.exercises.exerciseList[i].name)")
            let newEntry = ExerciseState(context: persistenceController.container.viewContext)
            newEntry.id = Int16(i)
            newEntry.isAdded = true
            newEntry.name = appData.exercises.exerciseList[i].name
            do {
                try persistenceController.container.viewContext.save()
            } catch {
                // Show some error here
            }
        }
    }
    //
    func initDB() {
        if !isReset {
        //condition that if activities exsist then do not init
        print("Initialising DB ... ")
        for e in exerciseState {
            print("Exercise State DB Item: \(String(describing: e.name))")
        }
        if allActivities.isEmpty {
            addExerciseStates()
        } else {
            print("Exercise States Already Added")
        }
        //
        } else {
            resetExerciseState()
        }
    }
    func resetExerciseState() {
        if !exerciseState.isEmpty {
            for e in exerciseState {
                persistenceController.delete(object: e)
            }
            for e in exerciseState {
                print(String(describing: e.name))
            }
            addExerciseStates()
        }
    }
    ///Main Body
    var body: some Scene {
        WindowGroup {
            MotherView().environmentObject(viewRouter)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(appData)
                .onAppear() {
                    initDB()
                }
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
    }
    
    
}


