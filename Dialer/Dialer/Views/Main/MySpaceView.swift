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
    @State private var didCopyToClipBoard = false
    @State private var editedUSSDModel: NewDialingView.UIModel?

    private var rowBackground: Color {
        Color.secondary.opacity(colorScheme == .dark ? 0.1 : 0.15)
    }

    private var isEditingMode: Bool {
        editMode?.wrappedValue == .active
    }

    var body: some View {
        List {
            Section {
                NavigationLink {
                    ElectricityView()
                } label: {
                    Text("Buy Electricity")
                }

                TappeableText("Check Mobile Balance", onTap: store.checkMobileWalletBalance)
            } header: {
                HStack {
                    Text("Most Popular")
                    Spacer()
                    CopiedUSSDLabel()
                        .opacity(didCopyToClipBoard ? 1 : 0)
                }
            }
            .listRowBackground(rowBackground)

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
                                MainViewModel.performQuickDial(for: .other(code.ussd))

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
        .onAppear() {
            store.utilityDelegate = self
        }
    }

    private func observeUSSDChange(_ editedUSSD: NewDialingView.UIModel?) {
        if editedUSSD == nil {
            editMode?.wrappedValue = .inactive
        }
    }

    private func copyToClipBoard(fullCode: String) {
        UIPasteboard.general.string = fullCode
        withAnimation { didCopyToClipBoard = true }

        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            withAnimation {
                didCopyToClipBoard = false
            }
        }
    }
}

extension MySpaceView: UtilitiesDelegate {
    func didSelectOption(with code: DialerQuickCode) {
        copyToClipBoard(fullCode: code.ussd)
    }
}

#if DEBUG
struct MySpaceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MySpaceView()
                .environmentObject(MainViewModel())
        }
    }
}
#endif
