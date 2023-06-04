//
//  SummaryView.swift
//  Dialer
//
//  Created by Cédric Bahirwe on 04/06/2023.
//

import SwiftUI

struct SummaryView: View {
    @StateObject private var summaryVM = SummaryViewModel()
    var body: some View {
        VStack {
            Text("Aso")
            
        }
    }
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        SummaryView()
    }
}

final class SummaryViewModel: ObservableObject {
    
    
}
