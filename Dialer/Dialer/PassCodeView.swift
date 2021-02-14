//
//  PassCodeView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 14/02/2021.
//

import SwiftUI


struct PassCodeCodeView: UIViewRepresentable {
    
    
    
    @State var viewWidth: CGFloat = .zero
    @State var txtFirst: UITextField = UITextField()
    @State var txtSecond: UITextField = UITextField()
    @State var txtThird: UITextField = UITextField()
    @State var txtFourth: UITextField = UITextField()
    @State var txtFifth: UITextField = UITextField()
    
    @Environment(\.colorScheme) var colorScheme
    
    var action: ((String) -> ())
    
    let size  = UIScreen.main.bounds.size
    let fieldHeight: CGFloat = 80
    
    func beautify(field: UITextField)  {
        field.placeholder = ""
        field.clearButtonMode = .whileEditing
        field.isSecureTextEntry = true
        field.textColor = colorScheme == .light ?  UIColor.black : UIColor.white
        field.font = UIFont.systemFont(ofSize: 35, weight: .black)
        field.textAlignment = .center
        field.autocorrectionType = .no
        field.clearButtonMode = .never
        field.autocapitalizationType = .none
        field.textContentType = .password
        field.keyboardType = .numberPad
        field.heightAnchor.constraint(equalToConstant: fieldHeight).isActive = true
        field.widthAnchor.constraint(equalToConstant: viewWidth-10).isActive = true
        
        field.layer.borderColor = colorScheme == .light ?  UIColor.black.cgColor : UIColor.white.cgColor
        field.layer.borderWidth = 2
        field.layer.cornerRadius = 8
        
    }
    
    func updateViews(field: UITextField) {
        field.layer.borderColor = UIColor.label.cgColor
        field.textColor = UIColor.label
    }
    
    func makeUIView(context: Context) -> UIStackView {
        
        
        txtFirst.delegate = context.coordinator
        txtSecond.delegate = context.coordinator
        txtThird.delegate = context.coordinator
        txtFourth.delegate = context.coordinator
        txtFifth.delegate = context.coordinator
        
        beautify(field: txtFirst)
        beautify(field: txtSecond)
        beautify(field: txtThird)
        beautify(field: txtFourth)
        beautify(field: txtFifth)
        
    
        //Stack View
        let stackView   = UIStackView()
        stackView.axis  = .horizontal
        stackView.distribution  = .equalSpacing
        stackView.alignment = .center
        stackView.spacing   = 12.5

        stackView.addArrangedSubview(txtFirst)
        stackView.addArrangedSubview(txtSecond)
        stackView.addArrangedSubview(txtThird)
        stackView.addArrangedSubview(txtFourth)
        stackView.addArrangedSubview(txtFifth)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView

    }
    
    func updateUIView(_ uiViewController: UIStackView, context: Context) {
        
        updateViews(field: txtFirst)
        updateViews(field: txtSecond)
        updateViews(field: txtThird)
        updateViews(field: txtFourth)
        updateViews(field: txtFifth)
        

    }

    func makeCoordinator() -> PassCodeCodeView.Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: PassCodeCodeView
        
        init(parent: PassCodeCodeView) {
            self.parent = parent
        }
        
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            if !(string == "") {
                textField.text = string
                if textField == parent.txtFirst {
                    parent.txtSecond.becomeFirstResponder()
                }
                else if textField == parent.txtSecond {
                    parent.txtThird.becomeFirstResponder()
                }
                else if textField == parent.txtThird {
                    parent.txtFourth.becomeFirstResponder()
                } else if textField == parent.txtFourth {
                    parent.txtFifth.becomeFirstResponder()
                }
                else {
                    textField.resignFirstResponder()
                    let firstDigit = (parent.txtFirst.text ?? "")
                    let secondDigit = (parent.txtSecond.text ?? "")
                    let thirdDigit = (parent.txtThird.text ?? "")
                    let fourthDigit = (parent.txtFourth.text ?? "")
                    let fifthDigit = (parent.txtFifth.text ?? "")
                    
                    var passCode = ""
                    
                    passCode.append(firstDigit)
                    passCode.append(secondDigit)
                    passCode.append(thirdDigit)
                    passCode.append(fourthDigit)
                    passCode.append(fifthDigit)
                    
                    parent.action(passCode)
                    
                    parent.txtFirst.text = ""
                    parent.txtSecond.text = ""
                    parent.txtThird.text = ""
                    parent.txtFourth.text = ""
                    parent.txtFifth.text = ""
                }
                return false
            }
            return true
        }

        func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
            if (textField.text?.count ?? 0) > 0 {

            }
            return true
        }
    }
        
}
