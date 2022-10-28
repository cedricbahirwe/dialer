//
//  PinView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 14/05/2021.
//

import SwiftUI

struct PinView: View {
    @Binding var input: String
    public var isFullMode: Bool = false
    public var btnSize: CGFloat = 60

    private var buttons: [String] {
        var defaults: [String] = ["1","2","3","4","5","6","7","8","9","*","0"]
        
        defaults += isFullMode ? ["#"] : ["X"]
        return defaults
    }
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
        ], spacing: 10) {
            ForEach(buttons, id: \.self) { button in
                CircleButton(button, size: btnSize,
                             action: { addKey(button)})
                .foregroundColor(
                    button == "X" ?
                        Color.red :
                        Color(.label)
                )
                .opacity(!isFullMode && button == "*" ? 0 : 1)
                .opacity(input.isEmpty && button == "X" ? 0 : 1)
                
            }
        }
    }
    
    private func addKey(_ value: String) {
        if value == "X" {
            if !input.isEmpty {
                input.removeLast()
            }
        } else {
            input.append(value)
        }
    }
}

struct PinView_Previews: PreviewProvider {
    static var previews: some View {
        PinView(input: .constant("*182#"))
    }
}

struct CircleButton: View {
    
    let title: String
    let size: CGFloat
    let action: () -> Void

    
    init(_ title: String, size: CGFloat, action: @escaping () -> Void) {
        self.title = title
        self.size = size
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(width: size, height: size)
                .background(Color.gray.opacity(0.2))
                .clipShape(Circle())
        }
    }
}
