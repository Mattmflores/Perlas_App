//
//  ForismaticModel.swift
//  Jackie's App
//
//  Created by Matthew Flores on 10/7/25.
//

import Foundation

struct Quote: Decodable, Identifiable {
    let id = UUID()
    let text: String
    let author: String
    let quoteLink: String?
    let senderName: String?
    let senderLink: String?

    private enum CodingKeys: String, CodingKey {
        case quoteText, quoteAuthor, quoteLink, senderName, senderLink
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        // Forismatic returns empty strings sometimes — normalize them.
        self.text = (try c.decodeIfPresent(String.self, forKey: .quoteText) ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        self.author = (try c.decodeIfPresent(String.self, forKey: .quoteAuthor) ?? "Unknown").trimmingCharacters(in: .whitespacesAndNewlines)
        self.quoteLink = try c.decodeIfPresent(String.self, forKey: .quoteLink)
        self.senderName = try c.decodeIfPresent(String.self, forKey: .senderName)
        self.senderLink = try c.decodeIfPresent(String.self, forKey: .senderLink)
    }
}

enum QuoteAPIError: Error {
    case badURL
    case badServerResponse
}

struct QuoteAPI {
    static func fetchRandomQuote(lang: String = "en") async throws -> Quote {
        var components = URLComponents(string: "http://api.forismatic.com/api/1.0/")!
        components.queryItems = [
            .init(name: "method", value: "getQuote"),
            .init(name: "format", value: "json"),
            .init(name: "lang", value: lang)
        ]
        guard let url = components.url else { throw QuoteAPIError.badURL }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 15

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw QuoteAPIError.badServerResponse
        }

        // Forismatic sometimes returns invalid JSON with unescaped quotes.
        // Try strict decoding first, then fall back to a “fixed” string.
        do {
            return try JSONDecoder().decode(Quote.self, from: data)
        } catch {
            // Attempt to repair common issues (e.g., stray backslashes)
            if var s = String(data: data, encoding: .utf8) {
                s = s.replacingOccurrences(of: "\\'", with: "'")
                let fixed = Data(s.utf8)
                return try JSONDecoder().decode(Quote.self, from: fixed)
            }
            throw error
        }
    }
}
