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

    private var isEditing: Bool {
        editMode?.wrappedValue == .active
    }

    var body: some View {
        List {
            if !mySpaceStore.ussdCodes.isEmpty {
                Section {
                    ForEach(mySpaceStore.ussdCodes) { ussd in
                        HStack {
                            Text(ussd.title)
                                .fontWeight(.medium)

                            Spacer()

                            Text(ussd.ussd)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if isEditing {
                                editMode?.wrappedValue = .active
                                editedUSSDModel = .init(ussd)
                            } else {
                                Task {
                                    await dialer.dialCode(for: ussd)
                                }
                            }
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) { mySpaceStore.deleteUSSD(ussd) } label: {
                                Label("Delete", systemImage: "trash")
                                    .labelStyle(.iconOnly)
                            }
                            .tint(.red)

                            Button {
                                editMode?.wrappedValue = .active
                                editedUSSDModel = .init(ussd)
                            } label: {
                                Label("Edit", systemImage: "info")
                                    .labelStyle(.iconOnly)
                            }
                        }
                    }
                    .onDelete(perform: mySpaceStore.deleteUSSD)
                    .listRowBackground(
                        Color(.systemBackground)
                            .clipShape(.capsule)
                    )
                } header: {
                    Text("Custom USSDs")
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                }
            }
        }
        .listRowSpacing(8)
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
            ToolbarItemGroup(placement: .topBarTrailing) {
                if !mySpaceStore.ussdCodes.isEmpty {
                    EditButton()
                        .tint(.accent)
                }

                Button {
                    editedUSSDModel = .init()
                } label: {
                    Label("Add USSD Code", systemImage: "plus")
                }
                .tint(.accent)
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
    let vm: MySpaceViewModel = .init()
    NavigationStack {
        MySpaceView()
            .task {
                vm.storeUSSD(try! .init(title: "Testing USSD", ussd: "*182#"))
            }
            .environmentObject(vm)

    }
    .preferredColorScheme(.dark)
}
