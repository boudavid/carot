//
//  Players.swift
//  Carot
//
//  Created by David Bou on 17/01/2024.
//

import Foundation

struct Players: Decodable, Equatable {
    let data: [Player]
    let meta: Meta
}

struct Player: Identifiable, Hashable, Codable, Equatable {
    let id: Int
    let firstName: String
    let lastName: String
    let position: String
    let team: Team
    var displayName: String {
        "\(firstName.first!). \(lastName)"
    }
}

struct PlayerPick: Identifiable, Equatable {
    let player: Player
    let date: Date
    var id: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return "\(formatter.string(from: date))-\(player.id)"
    }
}

extension Player {
    private enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case position
        case team
    }
}
