//
//  QuickDialingView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 16/08/2022.
//

import SwiftUI

struct QuickDialingView: View {
    @State private var composedCode: String = ""
    @State private var showInValidMsg: Bool = false
    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        VStack(spacing: 10) {
            Image("dialit.applogo")
                .resizable()
                .scaledToFit()
                .frame(width: 65)

            VStack(spacing: 10) {
                Group {
                    Text("Invalid code. Check it and try again.")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .opacity(showInValidMsg ? 1 : 0)
                        .padding(.horizontal)

                    LinearGradient(gradient: Gradient(colors: [Color.red, Color.blue]), startPoint: .leading, endPoint: .trailing)
                        .frame(height: 40)
                        .mask(
                            Text(composedCode)
                                .font(.largeTitle.weight(.semibold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                                .truncationMode(.head)
                        )
                        .padding(.horizontal, 20)
                        .opacity(composedCode.isEmpty ? 0 : 1)
                }

                PinView(input: $composedCode.animation(),
                        isFullMode: true, btnSize: 70)
                    .font(.title.bold())
                    .padding(.vertical, 10)
                    .padding(.horizontal)

                Button(action: {
                    dial(composedCode)
                }, label: {
                    Image(systemName: "phone.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 75, height: 75)
                        .clipShape(Circle())
                        .foregroundColor(.green)
                })
                .frame(maxWidth: .infinity)
                .overlay(bottomNavigationView)
                .padding(.bottom)
            }
        }
        .preferredColorScheme(.dark)
        .trackAppearance(.quickDialing)
    }

    private func dial(_ code: String) {
        // Basic Checks
        // This can be removed when user wants to dial a phone number ....
        if code.contains("*") && code.contains("#") && code.count >= 5 {
            if let telUrl = URL(string: "tel://\(code)"), UIApplication.shared.canOpenURL(telUrl) {
                UIApplication.shared.open(telUrl, options: [:], completionHandler: { _ in})

            } else {
                // Can not dial this code
                manageInvalidCode()
            }

        } else {
            // Supposed to be invalid, Can not dial this code
            manageInvalidCode()
        }
    }

    private func manageInvalidCode() {
        showInValidMsg = true
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            showInValidMsg = false
        }
    }

    private var bottomNavigationView: some View {
        HStack {

            Button(action: {
                dismiss()
            }, label: {
                Image(systemName: "arrow.backward.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .frame(width: 55, height: 55)
            })
            .frame(width: 75, height: 75)
            Spacer(minLength: 0)
            Button(action: {
                if !composedCode.isEmpty {
                    composedCode.removeLast()
                }
            }, label: {
                Image(systemName: "delete.left.fill")
                    .resizable()
                    .scaledToFit()
                    .padding(10)
                    .frame(width: 55, height: 55)
            })
            .disabled(composedCode.isEmpty)
            .opacity(composedCode.isEmpty ? 0 : 1)
            .frame(width: 75, height: 75)
        }
        .padding(.horizontal, 25)
        .foregroundColor(Color.red.opacity(0.8))
    }
}

#if DEBUG
struct QuickDialingView_Previews: PreviewProvider {
    static var previews: some View {
        QuickDialingView()
        //        .previewLayout(.fixed(width: 850, height: 900))
    }
}
#endif
