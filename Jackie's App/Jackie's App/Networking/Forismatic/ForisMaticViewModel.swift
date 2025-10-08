//
//  ForisMaticViewModel.swift
//  Jackie's App
//
//  Created by Matthew Flores on 10/7/25.
//

import Foundation

@MainActor
final class QuoteViewModel: ObservableObject {
    @Published var quote: Quote?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func load() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let q = try await QuoteAPI.fetchRandomQuote()
                self.quote = q
            } catch {
                self.errorMessage = error.localizedDescription
            }
            self.isLoading = false
        }
    }
}

