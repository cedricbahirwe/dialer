//
//  NewDialingView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 13/05/2021.
//

import SwiftUI

struct NewDialingView: View {
    @ObservedObject var store: MainViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var model: UIModel = UIModel()

    @State private var alertItem: (status: Bool, message: String) = (false, "")
    
    @FocusState  private var focusedField: Field?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    if titleAlreadyExists() {
                        Text("This name is already used by another USSD code.")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .animation(.default, value: model.editedCode)
                    }
                    TextField("What's your USSD code name?", text: $model.label.animation())
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
                    NumberField("Enter your USSD Code", text: $model.editedCode.animation(), keyboardType: .phonePad)
                        .focused($focusedField, equals: .code)
                        .submitLabel(.done)
                        .onChange(of: model.editedCode, perform: cleanCode)
                    
                    if ussdAlreadyExists() {
                        Text("This USSD code is already saved under another name")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .animation(.default, value: model.editedCode)
                    }
                }
                
                Button(action: saveUSSD) {
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
            .alert("USSD Validation", isPresented: $alertItem.status, actions: {
                Button("Okay", action: {})
            }, message: {
                Text(LocalizedStringKey(alertItem.message))
            })
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
}

// MARK: Keyboard
extension NewDialingView {
    func manageKeyboardFocus() {
        switch focusedField {
        case .title:
            focusedField = .code
        default:
            focusedField = nil
        }
    }

    enum Field {
        case title, code
    }
}

// MARK: Validation
extension NewDialingView {
    private func cleanedTitle(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespaces)
    }

    private func cleanCode(_ value: String) {
        withAnimation {
            model.editedCode = value.trimmingCharacters(in: .whitespaces)
        }
    }

    private func titleAlreadyExists() -> Bool {
        store.ussdCodes.contains { $0.title.lowercased() == cleanedTitle(model.label.lowercased()) }
    }

    private func ussdAlreadyExists() -> Bool {
        store.ussdCodes.contains { $0.ussd == model.editedCode }
    }

    private func isUSSDValid() -> Bool {
        !titleAlreadyExists() && !ussdAlreadyExists()
    }

    private func saveUSSD() {
        do {
            let newCode = try USSDCode(title: model.label,
                                       ussd: model.editedCode)
            store.storeUSSD(newCode)
            dismiss()
        } catch let error as USSDCode.USSDCodeValidationError  {
            alertItem = (true, error.description)
        } catch {
            alertItem = (true, error.localizedDescription)
        }
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
        NewDialingView(store: MainViewModel())
    }
}

