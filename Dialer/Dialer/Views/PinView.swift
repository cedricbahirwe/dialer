//
//  PinView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 14/05/2021.
//

import SwiftUI

struct PinView: View {
    
    @Binding var input: String
    public var fullMode: Bool = false
    public var btnSize: CGSize = CGSize(width: 60, height: 60)

    private var buttons: [String] {
        var defaults = ["1","2","3","4","5","6","7","8","9","*","0"]
        
        defaults += fullMode ? ["#"] : ["X"]
        return defaults
    }
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
        ], spacing: 10) {
            ForEach(buttons, id: \.self) { button in
                Button {
                    if button == "X" {
                        if !input.isEmpty {
                            input.removeLast()
                        }
                    } else {
                        input.append(button)
                    }
                } label: {
                    Text(button)
                        .frame(width: btnSize.width, height: btnSize.height)
                        .background(Color.gray.opacity(0.2))
                        .clipShape(Circle())
                }
                .frame(maxHeight: .infinity)
                .foregroundColor(
                    button == "X" ?
                        Color.red :
                        Color(.label)
                )
                
            }
        }
    }
}


extension Int {
    var stringBind: String {
        get { String(self) }
        set(value) { self = Int(value) ?? 0 }
    }
}


struct PinView_Previews: PreviewProvider {
    static var previews: some View {
        PinView(input: .constant("*182#"))
    }
}
