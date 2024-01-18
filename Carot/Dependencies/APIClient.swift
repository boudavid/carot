//
//  APIClient.swift
//  Carot
//
//  Created by David Bou on 17/01/2024.
//

import Dependencies
import Foundation

struct Meta: Decodable, Equatable {
//    let totalPages: Int
    let currentPage: Int
    let nextPage: Int?
    let perPage: Int
//    let totalCount: Int
}

struct APIClient {
    var fetchDateGames: @Sendable (Date) async throws -> Games
    var fetchGamesStats: @Sendable ([Int], Int) async throws -> Stats
    var searchPlayer: @Sendable (String) async throws -> Players
}

extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClient.self] }
        set { self[APIClient.self] = newValue }
    }
}

extension APIClient: DependencyKey {
    static let liveValue = APIClient(
        fetchDateGames: { date in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            
            var components = URLComponents(string: "https://www.balldontlie.io/api/v1/games")!
            components.queryItems = [
                URLQueryItem(name: "start_date", value: "\(formatter.string(from: date))"),
                URLQueryItem(name: "end_date", value: "\(formatter.string(from: date))")
            ]

            let (data, _) = try await URLSession.shared.data(from: components.url!)
            return try jsonDecoder.decode(Games.self, from: data)
        },
        fetchGamesStats: { gameIds, pageNumber in
            var components = URLComponents(string: "https://www.balldontlie.io/api/v1/stats")!
            components.queryItems = gameIds.map { URLQueryItem(name: "game_ids[]", value: "\($0)") }
            components.queryItems?.append(.init(name: "page", value: "\(pageNumber)"))
            components.queryItems?.append(.init(name: "per_page", value: "100"))
            
            let (data, _) = try await URLSession.shared.data(from: components.url!)
            return try jsonDecoder.decode(Stats.self, from: data)
        },
        searchPlayer: { query in
            var components = URLComponents(string: "https://www.balldontlie.io/api/v1/players")!
            components.queryItems = [
                URLQueryItem(name: "search", value: query),
            ]
            
            let (data, _) = try await URLSession.shared.data(from: components.url!)
            return try jsonDecoder.decode(Players.self, from: data)
        }
    )
}

private let jsonDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .iso8601)
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    decoder.dateDecodingStrategy = .formatted(formatter)
    return decoder
}()

extension Meta {
    private enum CodingKeys: String, CodingKey {
//        case totalPages = "total_pages"
        case currentPage = "current_page"
        case nextPage = "next_page"
        case perPage = "per_page"
//        case totalCount = "total_count"
    }
}
