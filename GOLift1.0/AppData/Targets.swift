//
//  Targets.swift
//  GOLift1.0
//
//  Created by L EE on 03/04/2021.
//

import Foundation

class Targets: ObservableObject {
    let targetsList: [Target]
    var primary: Target {
        targetsList[0]
    }
    init() {
        let url = Bundle.main.url(forResource: "targets",
                                  withExtension: "json")!
        let data = try! Data(contentsOf: url)
        targetsList = try! JSONDecoder().decode([Target].self, from: data)
    }
}
