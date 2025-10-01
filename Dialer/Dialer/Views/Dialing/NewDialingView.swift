//
//  NewDialingView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 13/05/2021.
//

import SwiftUI

struct NewDialingView: View {
    @ObservedObject var store: DialerService
    @State var model: UIModel = UIModel()
    var isEditing = false
     
    @Environment(\.dismiss) private var dismiss

    @State private var alertItem: (status: Bool, message: String) = (false, "")    
    @FocusState  private var focusedField: Field?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(spacing: 10) {
                    if titleAlreadyExists() {
                        Text("This name is already used by another USSD code.")
                            .font(.caption)
                            .foregroundStyle(.blue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .animation(.default, value: model.editedCode)
                    }
                    TextField("What's your USSD code name?", text: $model.label.animation())
                        .keyboardType(.default)
                        .disableAutocorrection(true)
                        .focused($focusedField, equals: .title)
                        .submitLabel(.next)
                        .foregroundStyle(.primary)
                        .padding()
                        .frame(height: 48)
                        .background(Color.primaryBackground)
                        .withNeumorphStyle()
                }
                VStack(spacing: 10) {
                    NumberField("Enter your USSD Code", text: $model.editedCode.animation(), keyboardType: .phonePad)
                        .focused($focusedField, equals: .code)
                        .submitLabel(.done)
                        .onChange(of: model.editedCode, perform: cleanCode)
                    
                    if ussdAlreadyExists() {
                        Text("This USSD code is already saved under another name")
                            .font(.caption)
                            .foregroundStyle(.blue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .animation(.default, value: model.editedCode)
                    }
                }
                
                Button(action: saveUSSD) {
                    Text("\(isEditing ? "Edit" : "Save") USSD")
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color.blue.opacity(isUSSDValid() ? 1 : 0.3))
                        .cornerRadius(8)
                        .foregroundStyle(Color.white)
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
            .navigationTitle("\(isEditing ? "Edit" : "Create") your own USSD code")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.primaryBackground.ignoresSafeArea().onTapGesture(perform: hideKeyboard))
            .onSubmit(manageKeyboardFocus)
            .trackAppearance(.newDialing)
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
            model.editedCode = value.withoutSpacing()
        }
    }

    private func titleAlreadyExists() -> Bool {
        if isEditing {
            return store.ussdCodes.contains {
                $0.id != model.id &&
                cleanedTitle($0.title.lowercased()) == cleanedTitle(model.label.lowercased())
            }
        } else {
           return store.ussdCodes.contains {
               cleanedTitle($0.title.lowercased()) == cleanedTitle(model.label.lowercased())
           }
        }
    }

    private func ussdAlreadyExists() -> Bool {
        if isEditing {
            return store.ussdCodes.contains {
                $0.id != model.id &&
                $0.ussd == model.editedCode
            }
        } else {
            return store.ussdCodes.contains { $0.ussd == model.editedCode }
        }
    }

    private func isUSSDValid() -> Bool {
        !titleAlreadyExists() && !ussdAlreadyExists()
    }

    private func saveUSSD() {
        do {
            let newCode = try USSDCode(title: model.label,
                                       ussd: model.editedCode)
            if isEditing {
                store.updateUSSD(newCode)
            } else {
                store.storeUSSD(newCode)
            }
            dismiss()
        } catch let error as USSDCode.USSDCodeValidationError  {
            alertItem = (true, error.description)
        } catch {
            alertItem = (true, error.localizedDescription)
        }
    }
}

extension NewDialingView {
    struct UIModel: Identifiable {
        var id: UUID
        var editedCode: String
        var label: String

        init(editedCode: String = "", label: String = "") {
            self.id = UUID()
            self.editedCode = editedCode
            self.label = label
        }

        init(_ ussdCode: USSDCode) {
            self.id = ussdCode.id
            self.editedCode = ussdCode.ussd
            self.label = ussdCode.title
        }
    }
}

#Preview {
    NewDialingView(store: DialerService())
}
