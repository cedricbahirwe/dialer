//
//  BaseViewModel.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 01/10/2025.
//  Copyright © 2025 Cédric Bahirwe. All rights reserved.
//
import Foundation

@MainActor class BaseViewModel: ObservableObject {
    @Published private(set) var isFetching = false

    func startFetch() {
        DispatchQueue.main.async {
            self.isFetching = true
        }
    }

    func stopFetch() {
        DispatchQueue.main.async {
            self.isFetching = false
        }
    }
}
