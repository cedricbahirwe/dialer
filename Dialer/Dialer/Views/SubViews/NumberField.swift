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
            .foregroundColor(.primary)
            .padding()
            .frame(height: 48)
            .background(Color.primaryBackground)
            .withNeumorphStyle()
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
