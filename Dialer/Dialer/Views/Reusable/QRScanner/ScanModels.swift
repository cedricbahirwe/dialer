//
//  ScanModels.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 14/07/2023.
//

import AVFoundation
import UIKit

/// An enum describing the ways CodeScannerView can hit scanning problems.
enum ScanError: Error {
    /// The camera could not be accessed.
    case badInput

    /// The camera was not capable of scanning the requested codes.
    case badOutput

    /// Initialization failed.
    case initError(_ error: Error)
  
    /// The camera permission is denied
    case permissionDenied
}

/// The result from a successful scan: the string that was scanned, and also the type of data that was found.
/// The type is useful for times when you've asked to scan several different code types at the same time, because
/// it will report the exact code type that was found.
struct ScanResult {
    /// The contents of the code.
    let string: String

    /// The type of code that was matched.
    let type: AVMetadataObject.ObjectType
    
    /// The image of the code that was matched
    let image: UIImage?
  
    /// The corner coordinates of the scanned code.
    let corners: [CGPoint]
}
