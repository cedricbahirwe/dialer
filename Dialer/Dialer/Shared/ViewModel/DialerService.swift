//
//  DialerService.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 14/02/2021.
//

import Foundation
import SwiftUI

private struct DialerServiceKey: EnvironmentKey {
    static let defaultValue = DialerService()
}

extension EnvironmentValues {
    var dialerService: DialerService {
        get { self[DialerServiceKey.self] }
        set { self[DialerServiceKey.self] = newValue }
    }
}

final class DialerService {
    /// Perform an airtime purchase transaction
    @MainActor func buyAirtime(_ transaction: AirtimeTransaction) async {
        await dialCode(for: transaction)
        Tracker.shared.logTransaction(record: .airtime(transaction))
    }

    /// Perform a Momo transaction
    /// - Parameter transaction: the user transaction
    func transferMoney(_ transaction: Transaction.Model) async {
        guard transaction.isValid else {
            Log.debug("Transaction is invalid: \(transaction.fullUSSDCode)")
            return
        }

        await dialCode(for: transaction)
        Tracker.shared.logTransaction(transaction: transaction.toParent())
    }

    /// Perform an independent dial, without storing or tracking.
    /// - Parameter code: a `DialerQuickCode`  code to be dialed.
    func dialCode(for dialCode: Dialable) async {
        guard let telUrl = try? PhoneService.shared.getDialURL(from: dialCode.fullUSSDCode) else {
            Log.debug("DialerService Can not dial this code: \(dialCode.fullUSSDCode)")
            return
        }

        do {
            try await PhoneService.shared.dial(telUrl)
            Log.debug("DialerService Successfully Dialed")
        } catch let error as DialingError {
            Log.debug("DialerService Interal Error: \(error.message)")
        } catch {
            Log.debug("DialerService Unknow Error: \(error.localizedDescription)")
        }
    }
}
