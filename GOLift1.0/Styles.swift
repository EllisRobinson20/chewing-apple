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

extension Color {
    func paint(name: String) -> Color {
        let timeElapsed = helper.muscleDictionary[name]
        var red = CGFloat(0.0)
        var green = CGFloat(0.0)
        var blue = CGFloat(0.0)
        var alpha = CGFloat(0.0)
        print("print body part called. Time elapsed value: \(String(describing: timeElapsed))")
        // if less than 24 hours
        if (timeElapsed ?? 145 < 24) {
            //red
            print("Value is Red")
            
            //var newColor = UIColor(red: 0.88, green: 0.02, blue: 0.00, alpha: 1.00)
            red = 0.88
            green = 0.02
            blue = 0.00
            alpha = 1.00
            
        } else // if more than 24 hours but less than 48 hours
        if (timeElapsed ?? 145 > 24 && timeElapsed ?? 145 < 48) {
            //opaque 50% red
            print("Value is Red")
            //color = UIColor(red: 0.88, green: 0.02, blue: 0.00, alpha: 0.50)
            red = 0.88
            green = 0.02
            blue = 0.00
            alpha = 0.50
            
        } else // if more than 48 but less than 72
        if (timeElapsed ?? 145 > 48 && timeElapsed ?? 145 < 72) {
            // amber / orange
            print("Value is Orange")
            //color = UIColor(red: 1.00, green: 0.78, blue: 0.00, alpha: 1.00)
            red = 1.00
            green = 0.78
            blue = 0.00
            alpha = 1.00
            
        } else // if more than 72 but less than 144
        if (timeElapsed ?? 145 > 72 && timeElapsed ?? 145 < 144) {
            // green
            print("Value is Green")
            //color = UIColor(red: 0.28, green: 0.89, blue: 0.19, alpha: 1.00)
            red = 0.28
            green = 0.89
            blue = 0.19
            alpha = 1.00
            
            
        } else // if more than 144
        if (timeElapsed ?? 0 > 144) {
           //default colour
            print("Value is Gray")
            //color = UIColor(red: 0.50, green: 0.50, blue: 0.50, alpha: 1.00)
            red = 0.50
            green = 0.50
            blue = 0.50
            alpha = 1.00
            
        } else
        if (timeElapsed == nil) {
            print("Value is Default Grey")
            red = 0.50
            green = 0.50
            blue = 0.50
            alpha = 1.00
        }

        print("Actual Value: \(red) : \(green) : \(blue)")
        
        return Color(UIColor(red: red, green: green, blue: blue, alpha: alpha))
    }
}


   
    
    


