//
//  Sessions.swift
//  GOLift1.0
//
//  Created by L EE on 03/04/2021.
//

import Foundation

class Sessions: ObservableObject {
    let sessions: [Session]
    var bicep: Session {
        sessions[0]
    }
    var pectoral: Session {
        sessions[1]
    }
    var abdominal: Session {
        sessions[2]
    }
    var quadricepts: Session {
        sessions[3]
    }
    init() {
        let url = Bundle.main.url(forResource: "sessions",
                                  withExtension: "json")!
        let data = try! Data(contentsOf: url)
        sessions = try! JSONDecoder().decode([Session].self, from: data)
    }
}
