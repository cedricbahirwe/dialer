//
//  MySpaceView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 19/11/2021.
//  Update by Cédric Bahirwe on 16/08/2022.
//

import SwiftUI

struct MySpaceView: View {
    // MARK: - Environment Properties
    
    @EnvironmentObject private var store: MainViewModel
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.editMode) private var editMode

    // MARK: - Private Properties
    
    @State private var editedUSSDModel: NewDialingView.UIModel?

    private var rowBackground: Color {
        Color.secondary.opacity(colorScheme == .dark ? 0.1 : 0.15)
    }

    private var isEditingMode: Bool {
        editMode?.wrappedValue == .active
    }

    var body: some View {
        List {
            if !store.ussdCodes.isEmpty {
                Section("Other") {
                    ForEach(store.ussdCodes) { code in
                        HStack {
                            Text(LocalizedStringKey(code.title))
                            
                            Spacer()
                            if editMode?.wrappedValue.isEditing == true {
                                Text("Edit")
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .frame(maxHeight: .infinity)
                                    .frame(width: 60)
                                    .background(Color.blue)
                                    .clipShape(Capsule())
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if isEditingMode {
                                editedUSSDModel = .init(code)
                            } else {
                                Task {
                                    await MainViewModel.performQuickDial(for: .other(code.ussd))
                                }
                                
                            }
                        }
                    }
                    .onDelete(perform: store.deleteUSSD)
                }
                .listRowBackground(rowBackground)
            }
        }
        .background(Color.primaryBackground)
        .navigationTitle("My Space")
        .sheet(item: $editedUSSDModel.onChange(observeUSSDChange)) { newCode in
            NewDialingView(store: store,
                           model: newCode,
                           isEditing: isEditingMode)
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button {
                    editedUSSDModel = .init()
                } label: {
                    Label("Add USSD Code", systemImage: "plus")
                }

                if !store.ussdCodes.isEmpty {
                    EditButton()
                }
            }
        }
        .trackAppearance(.mySpace)
    }

    private func observeUSSDChange(_ editedUSSD: NewDialingView.UIModel?) {
        if editedUSSD == nil {
            editMode?.wrappedValue = .inactive
        }
    }
}

struct MySpaceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MySpaceView()
                .environmentObject(MainViewModel())
        }
    }
}
