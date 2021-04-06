//
//  Session.swift
//  GOLift1.0
//
//  Created by L EE on 03/04/2021.
//

import Foundation

struct Session: Decodable, Identifiable {
    
    let id: Int
    let muscleName: String
    let muscleIndexPosition: Int

}
