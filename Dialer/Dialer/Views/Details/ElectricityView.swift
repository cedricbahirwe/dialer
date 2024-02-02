//
//  ElectricityView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 12/12/2021.
//

import SwiftUI

struct ElectricityView: View {
    @EnvironmentObject private var store: MainViewModel
    @State private var didCopyToClipBoard: Bool = false
    @State private var meterNumber: String = ""
    @State private var amount: String = ""
    
    private var isValidMeter: Bool {
        meterNumber.count >= 10
        
    }
    
    private var canSaveMeterNumber: Bool {
        isValidMeter && !store.containsMeter(with: meterNumber)
    }
    private var isValidAmount: Bool { (Int(amount) != nil) }
    private var isValidTransaction: Bool {
        isValidMeter && isValidAmount
    }
    
    private var amountHintView: Text {
        if let amount = Int(amount) {
            return Text(amount >= 600 ? "" : "The amount must be greater or equal to 600 RWF")
        } else {
            return Text("You have entered an invalid amount.")
        }
    }
    
    @Environment(\.colorScheme)
    private var colorScheme
    private var rowBackground: Color {
        Color.secondary.opacity(colorScheme == .dark ? 0.1 : 0.15)
    }
    init() {
        UITableView.appearance().backgroundColor = UIColor.primaryBackground
    }
    
    var body: some View {
        VStack(spacing: 0) {
           
            VStack(spacing: 28) {
                VStack(spacing: 10) {
                    if !amount.isEmpty {
                        amountHintView
                            .font(.caption).foregroundColor(.blue)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .animation(.default, value: amount)
                    }
                    
                    NumberField("Enter Amount", text: $amount.animation())
                }
                
                VStack(spacing: 10) {
                    HStack {
                        
                        NumberField("Enter Meter Number", text: $meterNumber)
                        Button(action: {
                            hideKeyboard()
                            do {
                                let meter = try ElectricityMeter(meterNumber)
                                store.storeMeter(meter)

                            } catch {
                                Tracker.shared.logError(error: error)
                                Log.debug(error, "Meter Error")
                            }
                        }){
                            Text("Save")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                                .frame(height: 48)
                                .background(Color.primary)
                                .cornerRadius(8)
                                .foregroundColor(Color(.systemBackground))
                        }
                            .disabled(!canSaveMeterNumber)
                            .opacity(canSaveMeterNumber ? 1 : 0.4)
                            .animation(.easeInOut, value: canSaveMeterNumber)
                    }
                    
                    Text("The meter number should have at least 10 digits.")
                        .font(.caption).foregroundColor(.blue)
                }
                                
                HStack {
                    if UIApplication.hasSupportForUSSD {
                        Button(action: {
                            hideKeyboard()
                            store.getElectricity(for: meterNumber, amount: Int(amount)!)
                        }) {
                            Text("Dial Electricity USSD")
                                .font(.footnote.bold())
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Color.blue.opacity(isValidMeter ? 1 : 0.3))
                                .cornerRadius(8)
                                .foregroundColor(Color.white)
                        }
                        .disabled(isValidTransaction == false)

                        Button(action: copyToClipBoard) {
                            Image(systemName: "doc.on.doc.fill")
                                .frame(width: 48, height: 48)
                                .background(Color.blue.opacity(isValidTransaction ? 1 : 0.3))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                        .disabled(isValidTransaction == false || didCopyToClipBoard)
                    } else {
                        Button(action: copyToClipBoard) {
                            Label("Copy USSD code", systemImage: "doc.on.doc.fill")
                                .foregroundColor(.white)
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                                .background(Color.blue.opacity(isValidTransaction ? 1 : 0.3))
                                .cornerRadius(8)
                                .foregroundColor(Color.white)
                        }
                        .disabled(isValidTransaction == false || didCopyToClipBoard)
                    }
                }

                if didCopyToClipBoard {
                    CopiedUSSDLabel()
                }
            
            }.padding()
            
            List {
                Section("Saved Meters") {
                    ForEach(store.elecMeters) { meter in
                        TappeableText(LocalizedStringKey(meter.number),
                                      onTap: { fillMeterField(with: meter.number) })
                    }
                    .onDelete(perform: store.deleteMeter)
                }
                .listRowBackground(rowBackground)
                .opacity(store.elecMeters.isEmpty ? 0 : 1)
            }
        }
        .background(
            Color.primaryBackground.ignoresSafeArea()
                        .onTapGesture(perform: hideKeyboard)
        )
        .navigationTitle("Buy Electricity")
        .onAppear(perform: store.retrieveMeterNumbers)
    }
    
    private func fillMeterField(with value: String) {
        guard meterNumber != value else { return }
        meterNumber = value
    }

    private func copyToClipBoard() {
        guard let amount = Int(amount) else { return }
        let fullCode = DialerQuickCode.electricity(meter: meterNumber, amount: amount, code: store.pinCode)
        UIPasteboard.general.string = fullCode.ussd
        withAnimation { didCopyToClipBoard = true }

        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            withAnimation {
                didCopyToClipBoard = false
            }
        }
    }
}

struct ElectricityView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ElectricityView()
                .environmentObject(MainViewModel())
        }
        .environment(\.colorScheme, .dark)
    }
}
