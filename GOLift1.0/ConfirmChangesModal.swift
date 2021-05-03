//
//  ConfirmChangesModal.swift
//  GOLift1.0
//
//  Created by L EE on 01/05/2021.
//

import SwiftUI

struct ConfirmChangesModal: View {
    let textPrompt: String
    var body: some View {
        VStack(alignment: .center) {
            
            Text(textPrompt)
                .multilineTextAlignment(.center)
            
        }
        .padding()
    }
}


