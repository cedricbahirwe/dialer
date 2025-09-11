//
//  TipPickerView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 12/09/2025.
//  Copyright © 2025 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

struct TipPickerView: View {
    @ObservedObject var viewModel: TipViewModel
    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 2)

    var body: some View {
        VStack(alignment: .leading) {
            Text("Select an amount")
                .font(.headline)
                .padding(.bottom, 4)

            if viewModel.products.isEmpty {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity, alignment: .center)
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(viewModel.products) { product in
                        TipItemView(
                            product: product,
                            isSelected: viewModel.selectedProduct == product,
                            action: {
                                withAnimation {
                                    viewModel.selectedProduct = product
                                }
                            }
                        )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    TipPickerView(viewModel: .init())
}
