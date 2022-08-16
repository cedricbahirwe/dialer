//
//  NewDialingView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 13/05/2021.
//

import SwiftUI

struct NewDialingView: View {
    @ObservedObject var store: MainViewModel

    @State private var model: UIModel = UIModel()
    private var titleAlreadyExists: Bool { true }
    private var ussdAlreadyExists: Bool { true }

    @FocusState  private var focusedField: Field?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    if titleAlreadyExists {
                        Text("This name is already used by another USSD code.")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .animation(.default, value: model.editedCode)
                    }
                    TextField("What's your USSD code name?", text: $model.label)
                        .keyboardType(.default)
                        .disableAutocorrection(true)
                        .focused($focusedField, equals: .title)
                        .submitLabel(.next)
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
                }
                VStack(spacing: 10) {


                    NumberField("Enter your USSD Code", text: $model.editedCode, keyboardType: .phonePad)
                        .focused($focusedField, equals: .code)
                        .submitLabel(.done)

                    if ussdAlreadyExists {
                        Text("This USSD code is already saved under another name")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .animation(.default, value: model.editedCode)
                    }
                }

                Button(action: { }) {
                    Text("Save USSD")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.blue.opacity(isUSSDValid() ? 1 : 0.3))
                        .cornerRadius(8)
                        .foregroundColor(Color.white)
                }
                .disabled(isUSSDValid() == false)


                Spacer()
            }
            .padding()
            .navigationTitle("Save your own code")
            .background(Color.primaryBackground.ignoresSafeArea().onTapGesture(perform: hideKeyboard))
            .onSubmit(manageKeyboardFocus)
            .onAppear() {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.6) {
                    focusedField = .title
                }
            }
        }
    }

    private func isUSSDValid() -> Bool {
        return false
    }

    func manageKeyboardFocus() {
        switch focusedField {
        case .title:
            focusedField = .code
        default:
            focusedField = nil
        }
        //        getSearchableUsers()
    }
    enum Field {
        case title, code
    }
}

extension NewDialingView {
    struct UIModel {
        var editedCode: String = ""
        var label: String = ""
    }
}

struct NewDialingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NewDialingView(store: MainViewModel())
        }
        //        .previewLayout(.fixed(width: 850, height: 900))
    }
}

