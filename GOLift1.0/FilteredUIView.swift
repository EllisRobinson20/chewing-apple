//
//  SwiftUIView.swift
//  GOLift1.0
//
//  Created by L EE on 09/04/2021.
//

import SwiftUI

struct FilteredUIView: View {
//    @FetchRequest(
//        sortDescriptors: [],
//        predicate: NSPredicate(format: "exerciseName == %@", "\(filterExercise)"))
//        private var activity: FetchedResults<Activity>
    var fetchRequest: FetchRequest<Activity>
    var activity: FetchedResults<Activity> { fetchRequest.wrappedValue }
    @State var text: String = ""
    
    
    
    var body: some View {
        Text(text)
        
    }
    
    init(filterExercise: String)  {
        let predicate1 = NSPredicate(format: "exerciseName == %@", "\(filterExercise)")
        
        fetchRequest = FetchRequest<Activity>(
                                              sortDescriptors: []
                                               )
        text = fetchRequest.wrappedValue.first?.exerciseName ?? "nill"
       
    }
    
}





