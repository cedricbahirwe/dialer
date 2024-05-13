//
//  NumberField.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 12/12/2021.
//

import SwiftUI

struct NumberField: View {
    init(_ placeholder: LocalizedStringKey,
         text: Binding<String>,
         keyboardType: UIKeyboardType = .numberPad) {
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        _text = text
    }
    
    private let placeholder: LocalizedStringKey
    private let keyboardType: UIKeyboardType
    @Binding private var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .keyboardType(keyboardType)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .foregroundStyle(.primary)
            .padding()
            .frame(height: 48)
            .background(Color.primaryBackground)
            .withNeumorphStyle()
            .font(.callout)
    }
}

#Preview {
    NumberField("placeholder", text: .constant(""))
        .padding()
        .previewLayout(.sizeThatFits)
}
