//
//  CodeScannerViewController.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 14/07/2023.
//

import SwiftUI
import AVFoundation

extension CodeScannerView {
    
    class CodeScannerViewController: UIViewController,
                                     AVCaptureMetadataOutputObjectsDelegate {
        
        var parentView: CodeScannerView!
        var codesFound = Set<String>()
        var didFinishScanning = false
        private let showViewfinder: Bool
        
        let fallbackVideoCaptureDevice = AVCaptureDevice.default(for: .video)
        
        init(showViewfinder: Bool = false, parentView: CodeScannerView) {
            self.parentView = parentView
            self.showViewfinder = showViewfinder
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            self.showViewfinder = false
            super.init(coder: coder)
        }
        
        var captureSession: AVCaptureSession?
        var previewLayer: AVCaptureVideoPreviewLayer!
        
        private lazy var viewFinder: UIImageView? = {
            guard let image = UIImage(named: "viewfinder") else {
                return nil
            }
            
            let imageView = UIImageView(image: image)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            return imageView
        }()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            self.addOrientationDidChangeObserver()
            self.setBackgroundColor()
            self.handleCameraPermission()
        }
        
        override func viewWillLayoutSubviews() {
            previewLayer?.frame = view.layer.bounds
        }
        
        @objc func updateOrientation() {
            guard let orientation = view.window?.windowScene?.interfaceOrientation else { return }
            guard let connection = captureSession?.connections.last, connection.isVideoOrientationSupported else { return }
            switch orientation {
            case .portrait:
                connection.videoOrientation = .portrait
            case .landscapeLeft:
                connection.videoOrientation = .landscapeLeft
            case .landscapeRight:
                connection.videoOrientation = .landscapeRight
            case .portraitUpsideDown:
                connection.videoOrientation = .portraitUpsideDown
            default:
                connection.videoOrientation = .portrait
            }
        }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            updateOrientation()
        }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            
            setupSession()
        }
        
        private func setupSession() {
            guard let captureSession = captureSession else {
                return
            }
            
            if previewLayer == nil {
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            }
            
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
            addviewfinder()
            
            reset()
            
            if (captureSession.isRunning == false) {
                DispatchQueue.global(qos: .userInteractive).async {
                    self.captureSession?.startRunning()
                }
            }
        }
        
        private func handleCameraPermission() {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .restricted:
                break
            case .denied:
                self.didFail(reason: .permissionDenied)
            case .notDetermined:
                self.requestCameraAccess {
                    self.setupCaptureDevice()
                    DispatchQueue.main.async {
                        self.setupSession()
                    }
                }
            case .authorized:
                self.setupCaptureDevice()
                self.setupSession()
                
            default:
                break
            }
        }
        
        private func requestCameraAccess(completion: (() -> Void)?) {
            AVCaptureDevice.requestAccess(for: .video) { [weak self] status in
                guard status else {
                    self?.didFail(reason: .permissionDenied)
                    return
                }
                completion?()
            }
        }
        
        private func addOrientationDidChangeObserver() {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(updateOrientation),
                name: Notification.Name("UIDeviceOrientationDidChangeNotification"),
                object: nil
            )
        }
        
        private func setBackgroundColor(_ color: UIColor = .black) {
            view.backgroundColor = color
        }
        
        private func setupCaptureDevice() {
            captureSession = AVCaptureSession()
            
            guard let videoCaptureDevice = parentView.videoCaptureDevice ?? fallbackVideoCaptureDevice else {
                return
            }
            
            let videoInput: AVCaptureDeviceInput
            
            do {
                videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            } catch {
                didFail(reason: .initError(error))
                return
            }
            
            if (captureSession!.canAddInput(videoInput)) {
                captureSession!.addInput(videoInput)
            } else {
                didFail(reason: .badInput)
                return
            }
            let metadataOutput = AVCaptureMetadataOutput()
            
            if (captureSession!.canAddOutput(metadataOutput)) {
                captureSession!.addOutput(metadataOutput)
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = parentView.codeTypes
            } else {
                didFail(reason: .badOutput)
                return
            }
        }
        
        private func addviewfinder() {
            guard showViewfinder, let imageView = viewFinder else { return }
            
            view.addSubview(imageView)
            
            NSLayoutConstraint.activate([
                imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                imageView.widthAnchor.constraint(equalToConstant: 200),
                imageView.heightAnchor.constraint(equalToConstant: 200),
            ])
        }
        
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            
            if (captureSession?.isRunning == true) {
                DispatchQueue.global(qos: .userInteractive).async {
                    self.captureSession?.stopRunning()
                }
            }
            
            NotificationCenter.default.removeObserver(self)
        }
        
        override var prefersStatusBarHidden: Bool {
            true
        }
        
        override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            .all
        }
        
        /** Touch the screen for autofocus */
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard touches.first?.view == view,
                  let touchPoint = touches.first,
                  let device = parentView.videoCaptureDevice ?? fallbackVideoCaptureDevice,
                  device.isFocusPointOfInterestSupported
            else { return }
            
            let videoView = view
            let screenSize = videoView!.bounds.size
            let xPoint = touchPoint.location(in: videoView).y / screenSize.height
            let yPoint = 1.0 - touchPoint.location(in: videoView).x / screenSize.width
            let focusPoint = CGPoint(x: xPoint, y: yPoint)
            
            do {
                try device.lockForConfiguration()
            } catch {
                return
            }
            
            // Focus to the correct point, make continiuous focus and exposure so the point stays sharp when moving the device closer
            device.focusPointOfInterest = focusPoint
            device.focusMode = .continuousAutoFocus
            device.exposurePointOfInterest = focusPoint
            device.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
            device.unlockForConfiguration()
        }
        
        func reset() {
            codesFound.removeAll()
            didFinishScanning = false
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }

                guard didFinishScanning == false else { return }

                let result = ScanResult(string: stringValue)
                found(result)
                didFinishScanning = true

            }
        }
        
        func found(_ result: ScanResult) {
            
            if parentView.shouldVibrateOnSuccess {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
            
            parentView.completion(.success(result))
        }
        
        func didFail(reason: ScanError) {
            parentView.completion(.failure(reason))
        }
    }
}
