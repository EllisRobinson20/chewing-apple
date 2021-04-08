

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
