//
//  CongratsViewController.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 05/07/2021.
//

import UIKit
import SwiftUI


extension CongratulationsView {
    internal struct CongratsView: UIViewControllerRepresentable {
        func makeUIViewController(context: Context) -> UIViewController {
            CongratsViewController()
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) { }
    }
}

fileprivate class CongratsViewController: UIViewController {
    

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        createParticles()
    }
    
    func createParticles() {
        let particleEmitter = CAEmitterLayer()
        
        particleEmitter.emitterPosition = CGPoint(x: view.center.x, y: -96)
        particleEmitter.emitterShape = .line
        particleEmitter.emitterSize = CGSize(width: view.frame.size.width, height: 1)
        
        let red = makeEmitterCell(color: UIColor.red)
        let green = makeEmitterCell(color: UIColor.yellow)
        let blue = makeEmitterCell(color: UIColor.green)
        let dialer = makeEmitterCell(color: UIColor.mainColor)
        
        particleEmitter.emitterCells = [red, green, blue, dialer]
        
        view.layer.addSublayer(particleEmitter)
    }
    
    
    func makeEmitterCell(color: UIColor) -> CAEmitterCell {
        let cell = CAEmitterCell()
        cell.birthRate = 3
        cell.lifetime = 7.0
        cell.lifetimeRange = 0
        cell.color = color.cgColor
        cell.velocity = 200
        cell.velocityRange = 50
        cell.emissionLongitude = CGFloat.pi
        cell.emissionRange = CGFloat.pi / 4
        cell.spin = 2
        cell.spinRange = 3
        cell.scaleRange = 0.5
        cell.scaleSpeed = -0.05
        
        cell.contents = drawImage().cgImage
        return cell
    }
    
    func drawImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 35, height: 35))
        return renderer.image { _ in
            // Draw image in circle
            let image =  UIImage(named: "star")!
            let size = CGSize(width: 32, height: 32)
            let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            image.draw(in: rect)
        }
    }
}


