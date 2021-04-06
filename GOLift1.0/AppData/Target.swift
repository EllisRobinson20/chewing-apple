//
//  Target.swift
//  GOLift1.0
//
//  Created by L EE on 03/04/2021.
//

import Foundation

struct Target: Decodable, Identifiable {
    
    let id: Int
    let targetName: String
    let repAmount: [Int]
    let interval : [Int]
    let speed : String
    let oneRepMax : [Int]
    let targetSets : [Int]

}
