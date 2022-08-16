//
//  NewDialingView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 13/05/2021.
//

import SwiftUI

struct NewDialingView: View {
    var body: some View {
        VStack {
            VStack(spacing: 10) {
                //                if transaction.type == .client && !transaction.amount.isEmpty {
                //                    feeHintView
                //                        .font(.caption).foregroundColor(.blue)
                //                        .frame(maxWidth: .infinity, alignment: .leading)
                //                        .animation(.default, value: transaction.estimatedFee)
                //                }

//                                NumberField("Enter Amount", text: $transaction.amount.animation())
            }
            VStack(spacing: 10) {
                if true {
                    Text("(selectedContact.names").font(.caption).foregroundColor(.blue)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    //                        .animation(.default, value: transaction.type)
                }
                //                NumberField(transaction.type == .client ?
                //                            "Enter Receiver's number" :
                //                                "Enter Merchant Code", text: $transaction.number.onChange(handleNumberField).animation())

                if true {
                    Text("The code should be a 5-6 digits number")
                        .font(.caption).foregroundColor(.blue)
                }
            }

            VStack(spacing: 18) {
                if true {
                    Button(action: {
                        //                        showContactPicker.toggle()
                    }) {
                        HStack {
                            Image(systemName: "person.fill")
                            Text("Pick a contact")
                        }
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .frame(height: 48)
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .shadow(color: .lightShadow, radius: 6, x: -6, y: -6)
                        .shadow(color: .darkShadow, radius: 6, x: 6, y: 6)
                    }
                }

                HStack {
                    if UIApplication.hasSupportForUSSD {
                        Button(action: { }) {
                            Text("Dial USSD")
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                            //                                .background(Color.blue.opacity(transaction.isValid ? 1 : 0.3))
                                .cornerRadius(8)
                                .foregroundColor(Color.white)
                        }
                        //                        .disabled(transaction.isValid == false)

                        Button(action: { }) {
                            Image(systemName: "doc.on.doc.fill")
                                .frame(width: 48, height: 48)
                            //                                .background(Color.blue.opacity(transaction.isValid ? 1 : 0.3))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                        }
                        //                        .disabled(transaction.isValid == false || didCopyToClipBoard)
                    } else {
                        Button(action: {}) {
                            Label("Copy USSD code", systemImage: "doc.on.doc.fill")
                                .foregroundColor(.white)
                                .font(.subheadline.bold())
                                .frame(maxWidth: .infinity)
                                .frame(height: 48)
                            //                                .background(Color.blue.opacity(transaction.isValid ? 1 : 0.3))
                                .cornerRadius(8)
                                .foregroundColor(Color.white)
                        }
                        //                        .disabled(transaction.isValid == false || didCopyToClipBoard)
                    }
                }
            }
            .padding(.top)

            Spacer()
        }
        .padding()
        .navigationTitle("Add your own code")
    }
}

struct NewDialingView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            NewDialingView()
        }
        //        .previewLayout(.fixed(width: 850, height: 900))
    }
}

