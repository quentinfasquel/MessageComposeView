//
//  ContentView.swift
//  MessageComposeViewExample
//
//  Created by Quentin Fasquel on 10/07/2024.
//

import MessageComposeView
import SwiftUI

struct ContentView: View {
    @State private var showMessageComposer: Bool = false
    var body: some View {
        VStack {
            Button("Compose a message") {
                showMessageComposer = true
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .messageComposeSheet(
            isPresented: $showMessageComposer,
            body: "Here's my message"
        )
    }
}

#Preview {
    ContentView()
}
