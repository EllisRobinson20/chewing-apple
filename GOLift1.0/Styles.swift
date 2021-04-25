//
//  Styles.swift
//  GOLift1.0
//
//  Created by L EE on 01/04/2021.
//

import Foundation
import SwiftUI

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
// Button gadient style
struct RadioButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? Color.secondary : Color.white)
            .padding(3)
            .background(Color.blue)
            .cornerRadius(15.0)
    }
}
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? Color.secondary : Color.white)
            .padding(3)
            .background(configuration.isPressed ? Color.blue : Color.gray)
            .cornerRadius(8.0)
    }
}
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? Color.secondary : Color.white)
            .padding(19)
            .background(configuration.isPressed ? Color.gray : Color.blue)
            .cornerRadius(16.0)
    }
}
struct DemoButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? Color.gray : Color.yellow)
    }
}
struct FFWDButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? Color.gray : Color.yellow)
    }
}
struct OptionsButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.white)
            .padding()
            .background(Color.blue)
            .cornerRadius(15.0)
            .opacity(helper.buttonOpacity)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)    }
}
struct ProgressViewStyleTop: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration).padding(.vertical)
            .frame(width: .infinity, height: 18)
            .foregroundColor(Color.green).opacity(0.5)
            .shadow(color: Color(red: 0, green: 1, blue: 0),
                    radius: 2.0, x: 0, y: 5.0)
    }
}
struct ProgressViewStyleBottom: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ProgressView(configuration).opacity(0.5)
            .shadow(color: Color(red: 1, green: 0, blue: 0.0),
                    radius: 0, x: 0, y: 5.0)
    }
    
}

struct ChevronToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        return HStack {
            configuration.label
            Spacer()
            Image(systemName: configuration.isOn ? "chevron.down" : "chevron.up")
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
                .onTapGesture { configuration.isOn.toggle() }
        }
    }
}
struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        return HStack {
            configuration.label
            Spacer()
            Image(systemName: configuration.isOn ? "checkmark.square" : "square")
                .resizable()
                .frame(width: 22, height: 22)
                .onTapGesture { configuration.isOn.toggle() }
        }
    }
}


