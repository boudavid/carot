//
//  Stats.swift
//  Carot
//
//  Created by David Bou on 17/01/2024.
//

struct Stats: Decodable, Equatable {
    let data: [PlayerStats]
    let meta: Meta
}

struct PlayerStats: Decodable, Equatable {
    struct Game: Decodable, Equatable {
        let id: Int
    }

    struct Player: Decodable, Equatable {
        let id: Int
        let firstName: String
        let lastName: String
        let position: String
        let teamId: Int
        var displayName: String {
            "\(firstName.first!). \(lastName)"
        }
    }
    
    let id: Int
    let game: Game
    let player: Player?
    let team: Team
    let minutes: String
    let points: Int
    let rebounds: Int
    let assists: Int
    let blocks: Int
    let steals: Int
    let fieldGoalsMade: Int
    let fieldGoalsAttempted: Int
    let fieldGoalsPercentage: Double
    let threePointsFieldGoalsMade: Int
    let threePointsFieldGoalsAttempted: Int
    let threePointsFieldGoalsPercentage: Double
    let freeThrowsMade: Int
    let freeThrowsAttempted: Int
    let freeThrowPercentage: Double
    let turnovers: Int
    let personalFouls: Int
}

extension PlayerStats {
    private enum CodingKeys: String, CodingKey {
        case id
        case game
        case player
        case team
        case minutes = "min"
        case points = "pts"
        case rebounds = "reb"
        case assists = "ast"
        case blocks = "blk"
        case steals = "stl"
        case fieldGoalsMade = "fgm"
        case fieldGoalsAttempted = "fga"
        case fieldGoalsPercentage = "fg_pct"
        case threePointsFieldGoalsMade = "fg3m"
        case threePointsFieldGoalsAttempted = "fg3a"
        case threePointsFieldGoalsPercentage = "fg3_pct"
        case freeThrowsMade = "ftm"
        case freeThrowsAttempted = "fta"
        case freeThrowPercentage = "ft_pct"
        case turnovers = "turnover"
        case personalFouls = "pf"
    }
}

extension PlayerStats.Player {
    private enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case position
        case teamId = "team_id"
    }
}

