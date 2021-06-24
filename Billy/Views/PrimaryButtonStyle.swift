//
//  PrimaryButtonStyle.swift
//  Billy
//
//  Created by Felipe Passos on 17/11/20.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    
    var fillColor: Color = .fintechGreen
    var disabledFillCollor: Color = .negativeRed
    var disabled: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        PrimaryButton(configuration: configuration, fillColor: disabled ? disabledFillCollor : fillColor)
    }
    
    struct PrimaryButton: View {
        let configuration: Configuration
        let fillColor: Color
        
        var body: some View {
            configuration.label
                .padding(15)
                .background(RoundedRectangle(cornerRadius: 10).fill(fillColor))
                .foregroundColor(.white)
                
        }
    }
}


struct PrimaryButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button(action: {}, label: {
            Text("Create a challenge")
        }).buttonStyle(PrimaryButtonStyle(disabled: true))
    }
}
