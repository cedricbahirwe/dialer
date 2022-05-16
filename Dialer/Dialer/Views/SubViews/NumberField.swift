//
//  NumberField.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 12/12/2021.
//

import SwiftUI

struct NumberField: View {
    init(_ placeholder: LocalizedStringKey, text: Binding<String>) {
        self.placeholder = placeholder
        _text = text
    }
    
    private let placeholder: LocalizedStringKey
    @Binding private var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(.numberPad)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .foregroundColor(.primary)
            .padding()
            .frame(height: 48)
            .background(Color.primaryBackground)
            .overlay(
                Rectangle()
                    .stroke(Color.darkShadow, lineWidth: 4)
                    .rotation3DEffect(.degrees(3), axis: (-0.05,0,0), anchor: .bottom)
                    .offset(x: 2, y: 2)
                    .clipped()
            )
            .overlay(
                Rectangle()
                    .stroke(Color.lightShadow, lineWidth: 4)
                    .rotation3DEffect(.degrees(3), axis: (-0.05,0,0), anchor: .bottom)
                    .offset(x: -2, y: -2)
                    .clipped()
            )

        //            .shadow(color: .lightShadow, radius: 6, x: -6, y: -6)
        //            .shadow(color: .darkShadow, radius: 6, x: 6, y: 6)
//            .overlay(
//                RoundedRectangle(cornerRadius: 10)
//                    .stroke(Color.darkShadow, lineWidth: 4)
//                    .offset(x: 2, y: 2)
//                    .clipped()
//            )
//            .overlay(
//                RoundedRectangle(cornerRadius: 10)
//                    .stroke(Color.lightShadow, lineWidth: 4)
//                    .offset(x: -2, y: -2)
//                    .clipped()
//            )
//            .cornerRadius(10)
            .font(.callout)
    }
}


struct NumberField_Previews: PreviewProvider {
    static var previews: some View {
        NumberField("placeholder", text: .constant(""))
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
