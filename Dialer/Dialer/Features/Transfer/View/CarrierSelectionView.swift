//
//  CarrierSelectionView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 09/11/2025.
//  Copyright © 2025 Cédric Bahirwe. All rights reserved.
//

import SwiftUI
import TipKit

enum DialerCarrier: String, CaseIterable {
    case mtnRwanda = "MTN Rwanda"
    case airtelRwanda = "Airtel Rwanda"
    
    var image: String {
        switch self {
        case .mtnRwanda:
            return "mtn.rwanda"
        case .airtelRwanda:
            return "airtel.rwanda"
        }
    }

    var color: Color {
        switch self {
        case .mtnRwanda:
            return .yellow
        case .airtelRwanda:
            return .red
        }
    }
}

struct CarrierSelectionView: View {
    @available(iOS 17.0, *)
    private var otherCarrierTip: OtherCarrierTip { OtherCarrierTip() }

    @State private var selectedCarrier: DialerCarrier? = nil
    let carrierOptions = [
        ("MTN Rwanda", "mtn.rwanda"),     // your asset names
        ("Airtel Rwanda", "airtel.rwanda")
    ]

    var body: some View {
        VStack(spacing: 20) {
            Text("Choose Your Mobile Carrier")
                .font(.title)
                .fontWeight(.semibold)
                .padding(.top)

            Group {
                Text("We use your carrier to personalize USSD transactions. You can update this choice later in Settings.")
            }
            .font(.callout)
            .multilineTextAlignment(.center)
            .foregroundStyle(.secondary)

            HStack(spacing: 24) {
                ForEach(DialerCarrier.allCases, id: \.self) { carrier in
                    Button(action: {
                        withAnimation {
                            selectedCarrier = carrier
                        }
                    }) {
                        VStack(spacing: 10) {
                            Image(carrier.image)
                                .resizable()
                                .frame(width: 48, height: 48)
//                                .clipShape(Circle())
                            Text(carrier.rawValue)
                                .font(.headline)

                            if selectedCarrier == carrier {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(carrier.color)
                            }
                        }
                        .padding()
                        .background(carrier == .airtelRwanda ? .clear : .clear)
                        .background()
//                        .background(selectedCarrier == carrier ? Color.accentColor.opacity(0.15) : Color(.systemBackground))
                        .cornerRadius(16)
                    }
                }
            }
            .frame(minHeight: 150)

            VStack(spacing: 12) {


                Divider()
                    .padding(.horizontal)
//                Button(action: {
//                    selectedCarrier = "other"
//                }) {
                if #available(iOS 26.0, *) {
                    Text("Other Carrier")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 4)
                        .popoverTip(otherCarrierTip, arrowEdge: .top)
                } else {
                    // Fallback on earlier versions
                }
//                }
//                if selectedCarrier == "other" {
//                    Text("Dial It currently supports MTN Rwanda and Airtel Rwanda. If your carrier isn’t supported, some features may be unavailable. You can update your carrier anytime in Settings.")
//                        .font(.footnote)
//                        .foregroundStyle(.red)
//                        .multilineTextAlignment(.center)
//                        .padding(.top, 4)
//                }
            }

//            Spacer()
        }
        .padding()
        .background(.regularMaterial)
    }
}


@available(iOS 17.0, *)
#Preview(traits: .sizeThatFitsLayout) {
    VStack {
        Spacer()

        CarrierSelectionView()
            .preferredColorScheme(.dark)
    }
}

@available(iOS 17.0, *)
private struct OtherCarrierTip: Tip {
    var title: Text {
        Text("Other Carriers")
    }

    var message: Text? {
        Text("Dial It currently supports MTN Rwanda and Airtel Rwanda. If your carrier isn’t supported, some features may be unavailable. You can update your carrier anytime in Settings.")
    }
}
