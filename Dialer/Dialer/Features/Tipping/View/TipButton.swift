//
//  TipButton.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 12/09/2025.
//  Copyright © 2025 Cédric Bahirwe. All rights reserved.
//

import SwiftUI

struct TipButton: View {
    @ObservedObject var viewModel: TipViewModel

    var body: some View {
        VStack(spacing: 8) {
            Button(action: {
                Task {
                    await viewModel.processTipping()
                }
            }) {
                HStack {
                    if viewModel.isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .padding(.trailing, 8)
                    }

                    Text(viewModel.isProcessing ? "Processing..." : "Tip \(viewModel.tipDisplayAmount)")
                        .fontWeight(.semibold)
                }
                .padding(8)
                .frame(maxWidth: .infinity)
            }
            .tint(.mainRed)
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canTip || viewModel.isProcessing)

            if viewModel.canTip {
                Text("You'll be charged \(viewModel.tipDisplayAmount)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}


//#Preview {
//    TipButton()
//}
