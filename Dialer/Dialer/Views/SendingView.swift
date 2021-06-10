//
//  SendingView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 10/06/2021.
//

import SwiftUI

struct SendingView: View {
    
    @State private var showContactPicker = false
    @State private var allContacts: [Contact] = []
    @State private var selectedContact: Contact = .init(names: "", phoneNumbers: [])
    var body: some View {
        VStack(spacing: 20) {
            TextField("Enter Amount", text: .constant("Enter Amount"))
                .keyboardType(.numberPad)
                .foregroundColor(.gray)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 0.5))
                .font(.footnote)
            
            TextField("Enter Mobile Number", text: $selectedContact.phoneNumbers.firstElement)
                .keyboardType(.numberPad)
                .textContentType(.telephoneNumber)
                .foregroundColor(.gray)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray, lineWidth: 0.5))
                .font(.footnote)
            
            Button(action: {
                allContacts = phoneNumberWithContryCode()
                showContactPicker.toggle()
            }) {
                HStack {
                    Image(systemName: "person.fill")
                    Text("Pick a Contact").bold().font(.footnote)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 45)
                .background(Color(.systemBackground))
                .cornerRadius(8)
                .shadow(color: Color(.darkGray), radius: 1, x: 2, y: 2)
                .foregroundColor(Color(red: 0.008, green: 0.087, blue: 0.254))
            }
            
            
            Button(action: {}) {
                Text("Submit").bold().font(.footnote)
                    .frame(maxWidth: .infinity)
                    .frame(height: 45)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .shadow(color: Color(.darkGray), radius: 1, x: 2, y: 2)
                    .foregroundColor(.black)
            }
            
            Spacer()
        }
        .padding(.top)
        .sheet(isPresented: $showContactPicker) {
            ContactsList(allContacts: $allContacts, selectedContact: $selectedContact)
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}
extension View {
    func phoneNumberWithContryCode() -> [Contact] {
          var resultingContacts: [Contact] = []
          let contacts = PhoneContacts.getContacts()
          for contact in contacts {
              if contact.phoneNumbers.count > 0  {
                  let contactPhoneNumbers = contact.phoneNumbers
                  let mtnNumbers = contactPhoneNumbers.filter {
                      //                    $0.label != "" ||
                      $0.value.stringValue.hasPrefix("078") ||
                          $0.value.stringValue.hasPrefix("+250") ||
                          $0.value.stringValue.hasPrefix("250")
                  }
                  
                  let numbers = mtnNumbers.compactMap { $0.value.value(forKey: "digits") as? String }
                  if mtnNumbers.isEmpty == false {
                      let newContact = Contact(names:contact.givenName + " " +  contact.familyName,phoneNumbers: numbers)
                      resultingContacts.append(newContact)
                  }
              }
          }
          return resultingContacts
      }
}


struct ContactsList: View {
    @Binding var allContacts: [Contact]
    @Binding var selectedContact: Contact
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        VStack(spacing: 8) {
            Text("Contacts").font(.largeTitle).bold().padding(.top, 10)
            List(allContacts.sorted(by: { $0.names < $1.names })) { contact in
                HStack(alignment: .top) {
                    Color(.label)
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(
                            Text(contact.names)
                                .foregroundColor(.white)
                                .font(.largeTitle)
                    )
                    VStack(alignment: .leading) {
                        Text(contact.names).font(.system(size: 18)).fontWeight(.semibold)
                        ForEach(contact.phoneNumbers, id: \.self) { phoneNumber in
                            Text(phoneNumber).foregroundColor(.red)
                        }.padding(.leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedContact = contact
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

#if DEBUG
struct SendingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            SendingView()
            //            ContactsList(allContacts: .constant(Contact.example), selectedContact: .constant(Contact.example[0]))
        }
    }
}
#endif
