//
//  GOLift1_0App.swift
//  GOLift1.0
//
//  Created by L EE on 28/03/2021.
//

import SwiftUI
@main
struct GOLift1_0App: App {
    @StateObject var viewRouter = ViewRouter()
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @StateObject var appData = AppData()
    
    @FetchRequest(sortDescriptors: [])
    private var exerciseStateDB: FetchedResults<ExerciseState>
    
    
    var body: some Scene {
        WindowGroup {
            MotherView().environmentObject(viewRouter)
               
            
            .environmentObject(appData)
            
            
            
        }
    }
    
}


