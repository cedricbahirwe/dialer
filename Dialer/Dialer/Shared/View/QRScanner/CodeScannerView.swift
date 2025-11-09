//
//  CodeScannerView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 14/07/2023.
//

import AVFoundation
import SwiftUI

struct CodeScannerView: UIViewControllerRepresentable {
    
    let codeTypes: [AVMetadataObject.ObjectType]
    let showViewfinder: Bool
    let shouldVibrateOnSuccess: Bool
    var videoCaptureDevice: AVCaptureDevice?
    var completion: (Result<ScanResult, ScanError>) -> Void
    
    init(
        codeTypes: [AVMetadataObject.ObjectType],
        showViewfinder: Bool = false,
        shouldVibrateOnSuccess: Bool = true,
        videoCaptureDevice: AVCaptureDevice? = AVCaptureDevice.bestForVideo,
        completion: @escaping (Result<ScanResult, ScanError>) -> Void
    ) {
        self.codeTypes = codeTypes
        self.showViewfinder = showViewfinder
        self.shouldVibrateOnSuccess = shouldVibrateOnSuccess
        self.videoCaptureDevice = videoCaptureDevice
        self.completion = completion
    }
    
    func makeUIViewController(context: Context) -> CodeScannerViewController {
        return CodeScannerViewController(showViewfinder: showViewfinder, parentView: self)
    }
    
    func updateUIViewController(_ uiViewController: CodeScannerViewController, context: Context) {
        uiViewController.parentView = self
    }
}

extension AVCaptureDevice {
    /// Return the Ultra Wide Camera on capable devices and the default Camera for Video otherwise.
    static var bestForVideo: AVCaptureDevice? {
        let deviceHasUltraWideCamera = !AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInUltraWideCamera], mediaType: .video, position: .back).devices.isEmpty
        return deviceHasUltraWideCamera ? AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) : AVCaptureDevice.default(for: .video)
    }
}
