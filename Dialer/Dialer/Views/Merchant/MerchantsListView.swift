//
//  MerchantsListView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 28/02/2023.
//

import SwiftUI

struct MerchantsListView: View {
    @EnvironmentObject var merchantStore: MerchantStore
    @State private var showCreateView = false
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
                ForEach(merchantStore.merchants) { merchant in
                    MerchantRow(merchant)
                }
                .onDelete(perform: merchantStore.deleteMerchants)
            }
            .navigationTitle("\(merchantStore.merchants.count) merchants")
            .overlay {
                if merchantStore.isFetching {
                    Color.black.opacity(0.8).ignoresSafeArea()
                    ProgressView()
                        .tint(.green)
                        .scaleEffect(2)
                }
            }
            .sheet(isPresented: $showCreateView) {
                CreateMerchantView(merchantStore: merchantStore)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {

                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCreateView.toggle()
                    } label: {
                        Image( systemName: "plus.circle.fill")
                            .imageScale(.large)
                    }
                }
            }
            .trackAppearance(.merchantList)
        }
    }
}

private extension MerchantsListView {
    struct MerchantRow: View {
        private let merchant: Merchant
        init(_ merchant: Merchant) {
            self.merchant = merchant
        }
        var body: some View {
            VStack(alignment: .leading) {
                Text(merchant.name)
                    .font(.title3.weight(.semibold))
                Text("Address: \(merchant.address ?? "-")")
                Text("Merchant Code: **\(merchant.code)**")
                Text("Owner: \(merchant.ownerId?.uuidString ?? "-")")
                    .font(.callout)
                Text("ID: \(merchant.hashCode.uuidString)")
                    .font(.caption)
                    .foregroundStyle(.gray)
                    .italic()
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        }
    }
}

#Preview {
    MerchantsListView()
        .environmentObject(MerchantStore())
}
