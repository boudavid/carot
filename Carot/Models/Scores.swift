//
//  Scores.swift
//  Carot
//
//  Created by David Bou on 17/01/2024.
//

struct GameScore: Equatable, Identifiable {
    static let mock = GameScore(
        id: 0,
        status: "Final",
        visitorTeam: .init(
            id: 1,
            name: "Mavericks",
            score: 101
        ),
        homeTeam: .init(
            id: 2,
            name: "Trail Blazers",
            score: 100
        )
    )
    
    struct Team: Equatable {
        let id: Int
        let name: String
        let score: Int
    }
    
    struct TeamsBestPicks: Equatable {
        let visitor: PlayerScore
        let home: PlayerScore
    }
    
    let id: Int
    let status: String
    let visitorTeam: Team
    let homeTeam: Team
    var teamsBestsPicks: TeamsBestPicks?
}

struct PlayerScore: Equatable, Comparable, Identifiable {
    struct Game: Equatable {
        let opponentName: String
        let score: String
    }
    
    static func < (lhs: PlayerScore, rhs: PlayerScore) -> Bool {
        lhs.score < rhs.score
    }
    
    static let mock = PlayerScore(
        id: 0,
        stats: .init(
            id: 0,
            game: .init(id: 0),
            player: .init(
                id: 0,
                firstName: "Luka",
                lastName: "Doncic",
                position: "G",
                teamId: 0
            ),
            team: .init(
                id: 0,
                name: "Mavericks",
                fullName: "Dallas Mavericks"
            ),
            minutes: "40",
            points: 42,
            rebounds: 11,
            assists: 14,
            blocks: 2,
            steals: 3,
            fieldGoalsMade: 13,
            fieldGoalsAttempted: 26,
            fieldGoalsPercentage: 0.5,
            threePointsFieldGoalsMade: 3,
            threePointsFieldGoalsAttempted: 9,
            threePointsFieldGoalsPercentage: 0.33,
            freeThrowsMade: 6,
            freeThrowsAttempted: 9,
            freeThrowPercentage: 0.66,
            turnovers: 5,
            personalFouls: 3
        ),
        game: .init(opponentName: "Trail Blazers", score: "101 - 100"),
        score: 42
    )
    
    let id: Int
    let stats: PlayerStats
    let game: Game
    let score: Int
}
