//
//  Games.swift
//  Carot
//
//  Created by David Bou on 17/01/2024.
//

struct Games: Decodable, Equatable {
    let data: [Game]
    let meta: Meta
}

struct Game: Decodable, Equatable {
    let id: Int
    let homeTeam: Team
    let visitorTeam: Team
    let homeTeamScore: Int
    let visitorTeamScore: Int
    let status: String
}

extension Game {
    private enum CodingKeys: String, CodingKey {
        case id
        case homeTeam = "home_team"
        case visitorTeam = "visitor_team"
        case homeTeamScore = "home_team_score"
        case visitorTeamScore = "visitor_team_score"
        case status
    }
}
