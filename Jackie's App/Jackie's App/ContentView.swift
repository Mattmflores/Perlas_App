//
//  ContentView.swift
//  Jackie's App
//
//  Created by Matthew Flores on 10/7/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var vm = QuoteViewModel()
    @State private var displayedQuote: Quote?
    @State private var opacity: Double = 1.0
    @AppStorage("musicOn") private var musicOn = true   // persists across launches

    var body: some View {
        ZStack {
            AnimatedBackground()

            VStack(spacing: 40) {
                // QUOTE AREA (unchanged)
                ZStack {
                    if let q = displayedQuote {
                        VStack(spacing: 8) {
                            Text("“\(q.text)”")
                                .font(.title2)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .foregroundStyle(.white)
                                .opacity(opacity)

                            Text(q.author.isEmpty ? "Unknown" : q.author)
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.8))
                                .opacity(opacity)
                        }
                    } else if vm.isLoading {
                        ProgressView("Loading quote…").foregroundStyle(.white)
                    } else {
                        Text("Tap the button for a quote.")
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                .frame(height: 280)

                // BUTTON + TOGGLE
                VStack(spacing: 12) {
                    Button(action: fadeToNewQuote) {
                        Text("New Quote")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                    }
                    .buttonStyle(GlassButtonStyle())
                    .padding(.horizontal, 60)

                    Toggle("Ambient Music", isOn: $musicOn)
                        .tint(.white)
                        .foregroundColor(.white)
                        .frame(width: 200)
                        .onChange(of: musicOn) { on in
                            on ? AudioManager.shared.startAmbientLoop()
                               : AudioManager.shared.stopAmbient()
                        }
                }
            }
            .padding()
        }
        .onAppear {
            Task { await vm.load(); displayedQuote = vm.quote }
            if musicOn { AudioManager.shared.startAmbientLoop() }
        }
        .onDisappear { AudioManager.shared.stopAmbient() }
    }

    private func fadeToNewQuote() {
        // Haptic only; music no longer touched here
        let gen = UIImpactFeedbackGenerator(style: .medium)
        gen.prepare(); gen.impactOccurred()

        withAnimation(.easeInOut(duration: 1.2)) { opacity = 0.0 }
        Task {
            try? await Task.sleep(nanoseconds: 1_200_000_000)
            await vm.load()
            displayedQuote = vm.quote
            withAnimation(.easeInOut(duration: 1.2)) { opacity = 1.0 }
        }
    }
}



// MARK: - Custom iOS-style button
struct GlassButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.white.opacity(0.25),
                        Color.white.opacity(0.1)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
            )
            .cornerRadius(14)
            .shadow(color: Color.black.opacity(0.4), radius: 6, y: 3)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
            .foregroundColor(.white)
    }
}

#Preview {
    ContentView()
}





