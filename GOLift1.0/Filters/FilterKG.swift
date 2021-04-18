//
//  FilterKG.swift
//  GOLift1.0
//
//  Created by L EE on 16/04/2021.
//

import SwiftUI

struct FilterKG: View {
 
    var f: Float = 0
    var s: String
    
    var body: some View {
        Text("\(f )" )
    }
    
    init(exerciseName: String) {
        s = exerciseName
        
    }
    
    mutating func getValue() {
        if s == "standing squat" {
            f = FilteredTextWeight().get().first?.oneRepMax ?? 0
            f = f * 10.0
        }
        
        
    }
    
}


