//
//  AppData.swift
//  GOLift1.0
//
//  Created by L EE on 03/04/2021.
//

import Foundation

class AppData: ObservableObject {
    var exercises: Exercises
    let sessions: Sessions
    let targets: Targets
    
    init() {
        exercises = Exercises()
        sessions = Sessions()
        targets = Targets()
    }
    
}
