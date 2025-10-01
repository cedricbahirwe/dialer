//
//  TipFormView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 12/09/2025.
//  Copyright © 2025 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

struct TipFormView: View {
    @ObservedObject var viewModel: TipViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Image(.dialitApplogo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .clipShape(.rect(cornerRadius: 15))
                    .padding()

                VStack(spacing: 12) {
                    Text("Privacy over profit")
                        .font(.title3.bold())

                    Text("Enjoying the app? Leave a tip to show your support. Your contribution helps us keep it free, private, and open-source—without ads, tracking, or compromises.")
                }

                TipPickerView(viewModel: viewModel)

                TipButton(viewModel: viewModel)
            }
            .padding()
        }
        .background(Color.white.opacity(0.01).onTapGesture(perform: hideKeyboard))
    }
}




#Preview {
    TipFormView(viewModel: .init())
}
