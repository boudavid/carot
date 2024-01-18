//
//  MyPick.swift
//  Carot
//
//  Created by David Bou on 17/01/2024.
//

import Dependencies
import SwiftUI

@MainActor
final class MyPickModel: ObservableObject {
    struct AvailablePlayerPick: Identifiable, Equatable, Comparable {
        static func < (lhs: AvailablePlayerPick, rhs: AvailablePlayerPick) -> Bool {
            lhs.player.lastName < rhs.player.lastName
        }
        
        let player: Player
        let opponent: String
        let isPlayingOnTheRoad: Bool
        var id: Int { player.id }
    }
    
    struct SearchResult: Identifiable, Equatable {
        enum Availability: Equatable {
            case available
            case unavailable(Date)
        }
        
        let player: Player
        let availability: Availability
        var id: Int { player.id }
    }
    
    let date: Date
    let games: [GameScore]
    @Published var last30PlayerPicks: [PlayerPick]
    @Published var availablePastPlayerPicks: [AvailablePlayerPick]
    @Published var searchQuery: String
    @Published var searchResults: [SearchResult]
    
    @Dependency(\.apiClient) var apiClient
    @Dependency(\.userDefaultsClient) var userDefaultsClient
    
    init(date: Date, games: [GameScore]) {
        self.date = date
        self.games = games
        self.last30PlayerPicks = []
        self.availablePastPlayerPicks = []
        self.searchQuery = ""
        self.searchResults = []
    }
    
    func onAppeared() -> Void {
        let playingTeams = games.reduce(into: []) { teams, game in teams.append(contentsOf: [game.visitorTeam, game.homeTeam]) }
        
        last30PlayerPicks = userDefaultsClient.fetchLast30PlayerPicks(date)
        availablePastPlayerPicks = userDefaultsClient.fetchPastPlayerPicks(date)
            .filter { playingTeams.map(\.id).contains($0.team.id) }
            .filter { !last30PlayerPicks.map(\.player.id).contains($0.id) }
            .compactMap { player in
                guard let game = games.first(where: {
                    $0.homeTeam.id == player.team.id
                    || $0.visitorTeam.id == player.team.id
                })
                else { return nil }
                let isPlayingOnTheRoad = game.visitorTeam.id == player.team.id
                let opponent = isPlayingOnTheRoad ? game.homeTeam.name : game.visitorTeam.name
                
                return .init(player: player, opponent: opponent.lowercased(), isPlayingOnTheRoad: isPlayingOnTheRoad)
            }
            .sorted()
    }
    
    func searchQueryChangeDebounced() async -> Void {
        guard !searchQuery.isEmpty else {
            return
        }
        do {
            let response = try await apiClient.searchPlayer(searchQuery)

            searchResults = response.data.map { player in
                .init(
                    player: player,
                    availability: availability(
                        for: player,
                        last30PlayerPicks: last30PlayerPicks
                    )
                )
            }
        } catch {
            print(error)
            searchResults = []
        }
    }
    
    private func availability(for player: Player, last30PlayerPicks: [PlayerPick]) -> SearchResult.Availability {
        guard let playerPick = last30PlayerPicks.first(where: { $0.player.id == player.id }) else {
            return .available
        }
        return .unavailable(playerPick.date)
    }
}

struct MyPickView: View {
    @ObservedObject var model: MyPickModel
    let onClose: () -> Void
    let onPlayerPicked: (Player) -> Void
    
    @FocusState private var textFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Search")) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField(
                            "Type a player name",
                            text: $model.searchQuery
                        )
                        .disableAutocorrection(true)
                        .focused($textFieldFocused)
                    }
                }
                if !model.searchResults.isEmpty {
                    Section(header: Text("Results")) {
                        List {
                            ForEach(model.searchResults) { searchResult in
                                switch searchResult.availability {
                                case .available:
                                    Button(action: { onPlayerPicked(searchResult.player) }) {
                                        HStack {
                                            Image(searchResult.player.team.name.lowercased())
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 30, height: 30)
                                            Text("\(searchResult.player.firstName) \(searchResult.player.lastName)")
                                        }
                                    }
                                case let .unavailable(date):
                                    Button(action: { onPlayerPicked(searchResult.player) }) {
                                        HStack {
                                            Image(searchResult.player.team.name.lowercased())
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 30, height: 30)
                                            Text("\(searchResult.player.firstName) \(searchResult.player.lastName)")
                                            Spacer()
                                            Text(dateFormatter.string(from: date.daysAfter(30)))
                                        }
                                    }
                                    .disabled(true)
                                }
                            }
                        }
                    }
                }
                Section(
                    header: HStack {
                        Text("Available past picks playing")
                        Spacer()
                        Text("Versus")
                    }
                ) {
                    List {
                        ForEach(model.availablePastPlayerPicks) { playerPick in
                            Button(action: { onPlayerPicked(playerPick.player) }) {
                                HStack {
                                    Image(playerPick.player.team.name.lowercased())
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                    Text(playerPick.player.displayName)
                                    Spacer()
                                    HStack {
                                        if playerPick.isPlayingOnTheRoad {
                                            Text("@")
                                        }
                                        Image(playerPick.opponent)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30, height: 30)
                                    }
                                }
                            }
                        }
                    }
                }
                Section(
                    header: HStack {
                        Text("Last 30 picks")
                        Spacer()
                        Text("Available on")
                    }
                ) {
                    List {
                        ForEach(model.last30PlayerPicks) { playerPick in
                            let containsSearchQuery = playerPick.player.firstName.contains(model.searchQuery)
                                || playerPick.player.lastName.contains(model.searchQuery)
                            
                            HStack {
                                Text(playerPick.player.displayName)
                                Spacer()
                                Text(dateFormatter.string(from: playerPick.date.daysAfter(30)))
                            }
                            .bold(containsSearchQuery)
                            .foregroundColor(containsSearchQuery ? .red : .primary)
                        }
                    }
                }
            }
            .navigationTitle("\(dateFormatter.string(from: model.date)) pick")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { onClose() }
                }
            }
        }
        .task(id: model.searchQuery) {
            do {
                try await Task.sleep(nanoseconds: NSEC_PER_SEC / 3)
                await model.searchQueryChangeDebounced()
            } catch {
            }
        }
        .onAppear {
            textFieldFocused = true
            model.onAppeared()
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d, yyyy"
    return formatter
}()
