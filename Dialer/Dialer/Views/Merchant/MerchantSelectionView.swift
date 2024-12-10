//
//  MerchantSelectionView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 10/12/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

struct MerchantSelectionView: View {
    @ObservedObject var merchantStore: MerchantStore
    var isPresented = false
    var selectedCode: String
    var onSelectMerchant: (Merchant) -> Void
    @FocusState private var isSearching: Bool
    @State private var searchQuery = ""
    @Environment(\.colorScheme) private var colorScheme
    private var rowBackground: Color {
        Color(.systemBackground).opacity(colorScheme == .dark ? 0.6 : 1)
    }

    @State private var isExpanded = false
    @State private var showMerchantCreation = false

    var searchedMerchants: [Merchant] {
        if searchQuery.isEmpty {
            merchantStore.merchants
        } else {
            merchantStore.merchants.filter({ merchant in
                merchant.name.range(of: searchQuery, options: [.caseInsensitive, .diacriticInsensitive]) != nil || merchant.code.range(of: searchQuery) != nil
            })
        }
    }

    var body: some View {
        VStack {
            if isPresented {
                HStack {
                    HStack(spacing: 2) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                            .padding(9)

                        TextField("Search by name or code", text: $searchQuery) { isEditing in
                            print("Searching ", isEditing)
                            withAnimation {
                                self.isSearching = isEditing
                            }
                        }
                        .font(.system(.callout, design: .rounded))
                        .focused($isSearching)
                        .submitLabel(.done)

                        if isSearching {
                            Button(action: clearSearch) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundStyle(.secondary)
                                    .padding(.trailing, 9)
                            }
                        }
                    }
                    .background(Color.offBackground)
                    .cornerRadius(6)

                    if isSearching {
                        Button(action: endEditing) {
                            Text("Cancel")
                                .font(.system(.body, design: .rounded))
                        }
                    }
                }
                .animation(.default, value: isSearching)
                .padding(.horizontal)
                .padding(.top)
            }

            List {
                if isPresented {
                    savedMerchantsContent
                } else {
                    merchantSelectionList
                }
            }
            .scrollContentBackground(isPresented ? .visible : .hidden)
        }
        .sheet(isPresented: $showMerchantCreation) {
            CreateMerchantView(merchantStore: merchantStore)
        }
        .sheet(isPresented: $isExpanded) {
            NavigationStack {
                if #available(iOS 16.4, *) {
                    MerchantSelectionView(
                        merchantStore: merchantStore,
                        isPresented: true,
                        selectedCode: selectedCode,
                        onSelectMerchant: onSelectMerchant
                    )
                    .presentationDetents([.medium, .large])
                    .presentationContentInteraction(.scrolls)
                } else {
                    MerchantSelectionView(
                        merchantStore: merchantStore,
                        isPresented: true,
                        selectedCode: selectedCode,
                        onSelectMerchant: onSelectMerchant
                    )
                    .presentationDetents([.medium, .large])
                }
            }
        }
        .toolbar {
            if isPresented {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button(action: {
                            isSearching = false
                        }) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 18, design: .rounded))
                                .foregroundStyle(.blue)
                                .padding(5)
                        }
                    }
                }
            }
        }
    }
}

private extension MerchantSelectionView {
    var merchantSelectionList: some View {
        Section {
            if merchantStore.merchants.isEmpty {
                Text("No Merchants Saved Yet.")
                    .opacity(0.5)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 50)

            } else {
                savedMerchantsContent
            }
        } header: {
            HStack {
                Text("My Merchants")
                    .font(.system(.body, design: .rounded))
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .textCase(nil)

                Spacer(minLength: 1)

                if merchantStore.isFetching {
                    ProgressView()
                        .tint(.blue)
                } else {
                    Button {
                        showMerchantCreation = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .imageScale(.large)
                    }

                    Button {
                        hideKeyboard()
                        isExpanded = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .imageScale(.large)
                    }
                }

            }
        } footer: {
            if !merchantStore.merchants.isEmpty {
                Text("Please make sure the merchant code is correct before dialing.\nNeed Help? Go to ***Settings -> Contact Us***")
            }
        }
        .listRowBackground(rowBackground)
    }

    private var savedMerchantsContent: some View {
        ForEach(isPresented ? searchedMerchants : merchantStore.merchants) { merchant in
            HStack {
                HStack(spacing: 4) {
                    if merchant.code == selectedCode {
                        Image(systemName: "checkmark")
                            .foregroundStyle(.blue)
                            .font(.body.weight(.semibold))
                    }

                    Text(merchant.name)
                        .lineLimit(1)
                }
                Spacer()
                Text("#\(merchant.code)")
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.blue)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture {
                onSelectMerchant(merchant)
            }
            .listRowInsets(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
        }
        .onDelete(perform: deleteMerchant)
    }

    private func deleteMerchant(at offSets: IndexSet) {
        merchantStore.deleteMerchants(at: offSets)
    }
}

private extension MerchantSelectionView {
    func clearSearch() {
        withAnimation {
            if searchQuery.isEmpty {
                endEditing()
            } else {
                searchQuery = ""
            }
        }
    }

    func endEditing() {
        withAnimation {
            searchQuery = ""
            isSearching = false
            hideKeyboard()
        }
    }
}
