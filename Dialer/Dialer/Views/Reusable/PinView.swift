//
//  PinView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 14/05/2021.
//

import SwiftUI

struct PinView: View {
    @Binding var input: String
    var isFullMode: Bool = false
    var btnSize: CGFloat = 50

    private var buttons: [String] {
        var defaults: [String] = ["1","2","3","4","5","6","7","8","9","*","0"]
        
        defaults += isFullMode ? ["#"] : ["X"]
        return defaults
    }
    
    private let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 10), count: 3)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(buttons, id: \.self) { button in
                
                PinButton(button, size: btnSize,
                          action: { handleKey(button)})
                .foregroundStyle(.primary)
                .opacity(!isFullMode && button == "*" ? 0 : 1)
                
            }
        }
    }
    
    private func handleKey(_ value: String) {
        if value == "X" {
            removeLastKey()
        } else {
            addKey(value)
        }
    }
    
    private func addKey(_ value: String) {
        input.append(value)
    }
    
    private func removeLastKey() {
        guard !input.isEmpty else { return }
        input.removeLast()
    }
}

#Preview {
    PinView(input: .constant("*182#"))
        .previewLayout(.sizeThatFits)
        .font(.title2)
}

extension PinView {
    struct PinButton: View {
        private let title: String
        private let size: CGFloat
        private let action: () -> Void

        init(_ title: String, size: CGFloat, action: @escaping () -> Void) {
            self.title = title
            self.size = size
            self.action = action
        }
        
        private var isDeleteBtn: Bool {
            title == "X"
        }

        var body: some View {
            Button(action: action) {
                Group {
                    if isDeleteBtn {
                        Image(systemName: "delete.left")
                    } else {
                        Text(title)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: size)
                .background(isDeleteBtn ? .clear : .offBackground) 
                .clipShape(.rect(cornerRadius: 5))
                .shadow(radius: 1, x: 0, y: 1)
            }
        }
    }
}
