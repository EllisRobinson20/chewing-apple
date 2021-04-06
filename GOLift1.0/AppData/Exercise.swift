//
//  Exercise.swift
//  GOLift1.0
//
//  Created by L EE on 03/04/2021.
//

import Foundation

struct Exercise: Decodable, Identifiable {
    
    let id: Int
    let name: String
    let resistanceIndex: [Int]
    let tutorial: String
    var selected: Bool = true

    mutating func toggleSelection() {
        selected = !selected
    }
}
