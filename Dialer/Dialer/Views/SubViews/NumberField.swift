//
//  NumberField.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 12/12/2021.
//

import SwiftUI

struct NumberField: View {
    init(_ placeholder: String, text: Binding<String>) {
        self.placeholder = placeholder
        _text = text
    }
    
    private let placeholder: String
    @Binding private var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(.numberPad)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .foregroundColor(.primary)
            .padding()
            .frame(height: 45)
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .overlay(RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.primary, lineWidth: 0.5))
            .font(.callout)
    }
}


struct NumberField_Previews: PreviewProvider {
    static var previews: some View {
        NumberField("placeholder", text: .constant(""))
    }
}
