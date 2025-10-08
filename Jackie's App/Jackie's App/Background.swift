//
//  Background.swift
//  Jackie's App
//
//  Created by Matthew Flores on 10/7/25.
//

import SwiftUI

struct AnimatedBackground: View {
    @State private var animate = false

    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.20, green: 0.00, blue: 0.20),  // deep maroon-plum
                Color(red: 0.25, green: 0.05, blue: 0.35),  // dark purple
                Color(red: 0.05, green: 0.05, blue: 0.25),  // navy tone
                Color(red: 0.15, green: 0.00, blue: 0.15)   // fade back to maroon
            ]),
            startPoint: animate ? .topLeading : .bottomTrailing,
            endPoint: animate ? .bottomTrailing : .topLeading
        )
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: animate)
        .onAppear { animate = true }
    }
}



