//
//  Settings.swift
//  WorkoutCave
//
//  Created by Cassie Wallace on 1/9/26.
//

import SwiftUI

struct Settings: View {
    @State var ftp: Int?
    
    var body: some View {
        List {
            Section("Set FTP") {
                TextField("FTP", value: $ftp, format: .number)
                    .textFieldStyle(.roundedBorder)
            }
            Section("Power Zones") {
                Text("**Zone 1:** TBA")
                Text("**Zone 2:** TBA")
                Text("**Zone 3:** TBA")
                Text("**Zone 4:** TBA")
                Text("**Zone 5:** TBA")
                Text("**Zone 6:** TBA")
                Text("**Zone 7:** TBA")
            }
        }
        .listStyle(.plain)
        .listRowSeparator(.hidden)
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    Settings()
}
