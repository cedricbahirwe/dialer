//
//  MerchantSelectionView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 10/12/2024.
//  Copyright © 2024 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

struct MerchantSelectionView: View {
    @ObservedObject var merchantStore: UserMerchantStore
    var isPresentedModally = false
    var selectedCode: String
    var onSelectMerchant: (Merchant) -> Void
    @FocusState private var isSearching: Bool
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @State private var searchQuery = ""
    @State private var isExpanded = false
    @State private var showMerchantCreation = false

    private var rowBackground: Color {
        Color(.systemBackground).opacity(colorScheme == .dark ? 0.6 : 1)
    }

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
            if isPresentedModally {
                HStack {
                    HStack(spacing: 2) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                            .padding(9)

                        TextField("Search by name or code", text: $searchQuery) { isEditing in
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
                if isPresentedModally {
                    savedMerchantsContent
                } else {
                    merchantSelectionList
                }
            }
            .scrollContentBackground(isPresentedModally ? .visible : .hidden)
        }
        .sheet(isPresented: $showMerchantCreation) {
            CreateMerchantView(merchantStore: merchantStore)
        }
        .sheet(isPresented: $isExpanded) {
            NavigationStack {
                if #available(iOS 16.4, *) {
                    MerchantSelectionView(
                        merchantStore: merchantStore,
                        isPresentedModally: true,
                        selectedCode: selectedCode,
                        onSelectMerchant: onSelectMerchant
                    )
                    .presentationDetents([.medium, .large])
                    .presentationContentInteraction(.scrolls)
                } else {
                    MerchantSelectionView(
                        merchantStore: merchantStore,
                        isPresentedModally: true,
                        selectedCode: selectedCode,
                        onSelectMerchant: onSelectMerchant
                    )
                    .presentationDetents([.medium, .large])
                }
            }
        }
        .toolbar {
            if isPresentedModally {
                ToolbarItem(placement: .keyboard) {
                    HStack {
                        Spacer()
                        Button(action: {
                            isSearching = false
                        }) {
                            Image(systemName: "chevron.down")
                                .font(.system(size: 18, design: .rounded))
                                .foregroundStyle(.accent)
                                .padding(5)
                        }
                    }
                }
            }
        }
    }
}

private extension MerchantSelectionView {
    var savedMerchantsContent: some View {
        SavedMerchantsContent(
            isPresentedModally: isPresentedModally,
            selectedCode: selectedCode,
            merchants: isPresentedModally ? searchedMerchants : merchantStore.merchants,
            onSelectMerchant: {
                onSelectMerchant($0)
                if isPresentedModally {
                    dismiss()
                }
            },
            onDeleteMerchant: deleteMerchant
        )
    }

    var merchantSelectionList: some View {
        Section {
            if merchantStore.merchants.isEmpty {
                Text("No Merchants saved yet.")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 50)
            } else {
                savedMerchantsContent
            }
        } header: {
            HStack {
                Button {
                    isExpanded = true
                } label: {
                    HStack(spacing: 2) {
                        Text("My Merchants")
                            .font(.system(.title3, design: .rounded, weight: .bold))
                            .textCase(nil)

                        Label("View more merchants", systemImage: "chevron.right")
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .labelStyle(.iconOnly)
                            .foregroundStyle(.secondary)
                    }
                }
                .foregroundStyle(.foreground)
                .disabled(merchantStore.merchants.isEmpty)

                Spacer(minLength: 1)

                if merchantStore.isFetching {
                    ProgressView()
                        .tint(.accent)
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
                    .disabled(merchantStore.merchants.isEmpty)
                }
            }
        } footer: {
            if !merchantStore.merchants.isEmpty {
                Text("Please make sure the merchant code is correct before dialing.  Need Help? Go to ***Settings -> Contact Us***")
            }
        }
        .listRowBackground(rowBackground)
    }

    struct SavedMerchantsContent: View {
        let isPresentedModally: Bool
        let selectedCode: String?
        let merchants: [Merchant]
        var onSelectMerchant: (Merchant) -> Void
        var onDeleteMerchant: (IndexSet) -> Void

        var body: some View {
            ForEach(merchants) { merchant in
                HStack {
                    HStack(spacing: 4) {
                        if merchant.code == selectedCode {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.accent)
                                .font(.body.weight(.semibold))
                        }

                        Text(merchant.name)
                            .lineLimit(1)
                    }
                    Spacer()
                    Text("#\(merchant.code)")
                        .font(.callout.weight(.medium))
                        .foregroundStyle(.accent)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture {
                    onSelectMerchant(merchant)
                }
                .listRowInsets(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
            }
            .onDelete(perform: onDeleteMerchant)
        }
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
