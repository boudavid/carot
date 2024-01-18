//
//  Teams.swift
//  Carot
//
//  Created by David Bou on 17/01/2024.
//

struct Team: Hashable, Codable, Equatable {
    let id: Int
    let name: String
    let fullName: String
}

extension Team {
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case fullName = "full_name"
    }
}
