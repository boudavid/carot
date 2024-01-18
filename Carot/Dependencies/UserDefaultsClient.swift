//
//  UserDefaultsClient.swift
//  Carot
//
//  Created by David Bou on 17/01/2024.
//

import Dependencies
import Foundation

struct UserDefaultsClient {
    var savePlayerPick: (Player, Date) -> Void
    var fetchPlayerPick: (Date) -> Player?
    var fetchLast30PlayerPicks: (Date) -> [PlayerPick]
    var fetchPastPlayerPicks: (Date) -> [Player]
}

extension DependencyValues {
    var userDefaultsClient: UserDefaultsClient {
        get { self[UserDefaultsClient.self] }
        set { self[UserDefaultsClient.self] = newValue }
    }
}

extension UserDefaultsClient: DependencyKey {
    static let liveValue = UserDefaultsClient(
        savePlayerPick: { player, date in
            guard let encodedPlayer = try? JSONEncoder().encode(player) else {
                return
            }
            UserDefaults.standard.set(encodedPlayer, forKey: playersPicksKey(for: date))
        },
        fetchPlayerPick: { date in
            guard let data = UserDefaults.standard.object(forKey: playersPicksKey(for: date)) as? Data,
                  let player = try? JSONDecoder().decode(Player.self, from: data)
            else { return nil }
            return player
        },
        fetchLast30PlayerPicks: { date in
            var playerPicks: [PlayerPick] = []
            
            for n in 1..<30 {
                let pickDate = date.daysBefore(n)
                
                guard let data = UserDefaults.standard.object(forKey: playersPicksKey(for: pickDate)) as? Data,
                      let player = try? JSONDecoder().decode(Player.self, from: data)
                else { continue }
                playerPicks.insert(.init(player: player, date: pickDate), at: 0)
            }
            return playerPicks
        },
        fetchPastPlayerPicks: { date in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy/MM/dd"
            
            guard let seasonStartDate = formatter.date(from: "2022/10/18") else {
                return []
            }
            var players = Set<Player>()
            let numberOfDays = abs(Calendar.current.numberOfDaysBetween(date, and: seasonStartDate))
        
            for n in 0..<numberOfDays {
                let pickDate = date.daysBefore(n)
                
                guard let data = UserDefaults.standard.object(forKey: playersPicksKey(for: pickDate)) as? Data,
                      let player = try? JSONDecoder().decode(Player.self, from: data)
                else { continue }
                players.insert(player)
            }
            return Array(players)
        }
    )
}

private let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}()

private func playersPicksKey(for date: Date) -> String {
    "players.picks.\(formatter.string(from: date))"
}

