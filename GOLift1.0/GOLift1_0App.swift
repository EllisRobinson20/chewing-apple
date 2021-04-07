//
//  GOLift1_0App.swift
//  GOLift1.0
//
//  Created by L EE on 28/03/2021.
//

import SwiftUI
@main
struct GOLift1_0App: App {
    let persistenceController = PersistenceController.shared
    @Environment(\.scenePhase) var scenePhase
    
    @StateObject var viewRouter = ViewRouter()
    
    //@Environment(\.managedObjectContext) private var viewContext
    //let persistenceContainer = PersistenceController.shared
    @StateObject var appData = AppData()
    
    //@FetchRequest(sortDescriptors: [])
    //private var exerciseStateDB: FetchedResults<ExerciseState>
    
    
    var body: some Scene {
        WindowGroup {
            MotherView().environmentObject(viewRouter)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            
            .environmentObject(appData)
            
            
            
        }
        .onChange(of: scenePhase) { _ in
            persistenceController.save()
        }
    }
    
}


