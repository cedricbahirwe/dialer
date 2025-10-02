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
    @EnvironmentObject private var mySpaceStore: MySpaceViewModel
    @Environment(\.dialerService) private var dialer
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.editMode) private var editMode

    // MARK: - Private Properties
    
    @State private var editedUSSDModel: CustomDialingModel?

    private var rowBackground: Color {
        Color.secondary.opacity(colorScheme == .dark ? 0.1 : 0.15)
    }

    private var isEditing: Bool {
        editMode?.wrappedValue == .active
    }

    var body: some View {
        List {
            if !mySpaceStore.ussdCodes.isEmpty {
                Section("Custom USSDs") {
                    ForEach(mySpaceStore.ussdCodes) { ussd in
                        HStack {
                            Text(ussd.title)

                            Spacer()
                            if editMode?.wrappedValue.isEditing == true {
                                Text("Edit")
                                    .font(.caption)
                                    .foregroundStyle(.white)
                                    .frame(maxHeight: .infinity)
                                    .frame(width: 60)
                                    .background(Color.blue)
                                    .clipShape(Capsule())
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if isEditing {
                                editedUSSDModel = .init(ussd)
                            } else {
                                Task {
                                    await dialer.dialCode(for: ussd)
                                }
                                
                            }
                        }
                    }
                    .onDelete(perform: mySpaceStore.deleteUSSD)
                }
//                .listRowBackground(rowBackground)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.primaryBackground)
        .overlay {
            if mySpaceStore.ussdCodes.isEmpty {
                VStack {
                   Text("👋🏽")
                        .font(.system(size: 60))
                    
                    Text("Welcome to your safe spot.")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                    
                    Text("Let's start by adding a new custom USSD")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    
                    Button("Add custom USSD Code") {
                        editedUSSDModel = .init()
                    }
                    .buttonStyle(.borderedProminent)
                    .buttonBorderShape(.capsule)
                    .padding()
                }
                .padding()
            }
        }
        .navigationTitle("My Space")
        .sheet(item: $editedUSSDModel.onChange(observeUSSDChange)) {
            NewDialingView(
                store: mySpaceStore,
                model: $0,
                isEditing: isEditing
            )
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    editedUSSDModel = .init()
                } label: {
                    Label("Add USSD Code", systemImage: "plus")
                }

                if !mySpaceStore.ussdCodes.isEmpty {
                    EditButton()
                }
            }
        }
        .trackAppearance(.mySpace)
    }

    private func observeUSSDChange(_ editedUSSD: CustomDialingModel?) {
        if editedUSSD == nil {
            editMode?.wrappedValue = .inactive
        }
    }
}

#Preview {
    NavigationStack {
        MySpaceView()
    }
}
