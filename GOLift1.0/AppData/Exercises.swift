//
//  Exercises.swift
//  GOLift1.0
//
//  Created by L EE on 03/04/2021.
//

import Foundation

class Exercises: ObservableObject {
    var exerciseList: [Exercise]
    var primary: Exercise {
        exerciseList[0]
    }
    init() {
        let url = Bundle.main.url(forResource: "exercises",
                                  withExtension: "json")!
        let data = try! Data(contentsOf: url)
        exerciseList = try! JSONDecoder().decode([Exercise].self, from: data)
    }
}
