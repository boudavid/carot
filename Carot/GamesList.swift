//
//  GamesList.swift
//  Carot
//
//  Created by David Bou on 17/01/2024.
//

import Dependencies
import SwiftUI
import SwiftUINavigation

@MainActor
final class GamesListModel: ObservableObject {
    enum MyPick: Equatable {
        case none
        case picked(Player)
        case score(PlayerScore)
        
        var player: Player? {
            guard case let .picked(player) = self else {
                return nil
            }
            return player
        }
        var playerScore: PlayerScore? {
            guard case let .score(playerScore) = self else {
                return nil
            }
            return playerScore
        }
    }
    
    enum Destination {
        case gameDetail(GameDetailModel)
        case top25(Top25Model)
        case playerDetail(PlayerScore)
        case myPick(MyPickModel)
    }
    
    @Published var date: Date
    @Published var games: [GameScore]
    @Published var isLoading: Bool
    @Published var playersScores: [PlayerScore] = []
    var playersScoresTopThree: [PlayerScore] {
        guard playersScores.count > 2 else {
            return []
        }
        return Array(playersScores[0...2])
    }
    @Published var myPick: MyPick
    @Published var destination: Destination?

    @Dependency(\.apiClient) var apiClient
    @Dependency(\.userDefaultsClient) var userDefaultsClient

    init(date: Date, destination: Destination? = nil) {
        self.date = date
        self.games = []
        self.isLoading = false
        self.playersScores = []
        self.myPick = .none
        self.destination = destination
    }
    
    func previousDayButtonTapped() -> Void {
        date = date.daysBefore(1)
        Task {
            await fetchGames()
        }
    }
    
    func nextDayButtonTapped() -> Void {
        date = date.daysAfter(1)
        Task {
            await fetchGames()
        }
    }
    
    func fetchGames() async -> Void {
        isLoading = true
        do {
            let response = try await apiClient.fetchDateGames(date)

            games = response.data.map { game in
                .init(
                    id: game.id,
                    status: game.status,
                    visitorTeam: .init(
                        id: game.visitorTeam.id,
                        name: game.visitorTeam.name,
                        score: game.visitorTeamScore
                    ),
                    homeTeam: .init(
                        id: game.homeTeam.id,
                        name: game.homeTeam.name,
                        score: game.homeTeamScore
                    ),
                    teamsBestsPicks: nil
                )
            }
            playersScores = []
            if let player = userDefaultsClient.fetchPlayerPick(date) {
                myPick = .picked(player)
            } else {
                myPick = .none
            }
            await fetchGamesStats(pageNumber: 1)
        } catch {
            isLoading = false
            print(error)
        }
    }
    
    func gameDetailTapped(game: GameScore) -> Void {
        destination = .gameDetail(.init(
            game: game,
            visitorTeamPlayersScores: playersScores.filter { $0.stats.player?.teamId == game.visitorTeam.id }
                .sorted(by: >),
            homeTeamPlayersScores: playersScores.filter { $0.stats.player?.teamId == game.homeTeam.id }
                .sorted(by: >),
            myPickPlayerScore: myPick.playerScore
        ))
    }
    
    func playerDetailTapped(playerScore: PlayerScore) -> Void {
        destination = .playerDetail(playerScore)
    }
    
    func playerDetailDismissed() -> Void {
        destination = nil
    }
    
    func viewTop25ButtonTapped() -> Void {
        if playersScores.count >= 25 {
            destination = .top25(.init(
                playersScores: Array(playersScores[0...25]),
                myPickPlayerScore: myPick.playerScore
            ))
        }
    }
    
    func myPickTapped() -> Void {
        destination = .myPick(.init(date: date, games: games))
    }
    
    func myPickCloseButtonTapped() {
        destination = nil
    }
    
    func myPickPlayerPicked(player: Player) -> Void {
        myPick = find(player, in: playersScores)
        userDefaultsClient.savePlayerPick(player, date)
        destination = nil
    }
    
    private func fetchGamesStats(pageNumber: Int) async -> Void {
        let gamesIds = games.map(\.id)

        guard !gamesIds.isEmpty else {
            isLoading = false
            return
        }
        isLoading = true
        do {
            let response = try await apiClient.fetchGamesStats(gamesIds, pageNumber)
            let playersScores: [PlayerScore] = response.data.compactMap { playerStats in
                guard let gameScore = games.first(where: { playerStats.team.id == $0.homeTeam.id || playerStats.team.id == $0.visitorTeam.id }) else {
                    return nil
                }
                let opponentName = playerStats.team.id == gameScore.homeTeam.id ? gameScore.visitorTeam.name : gameScore.homeTeam.name
                let score = playerStats.team.id == gameScore.homeTeam.id
                    ? "\(gameScore.homeTeam.score) - \(gameScore.visitorTeam.score)"
                    : "\(gameScore.visitorTeam.score) - \(gameScore.homeTeam.score)"
                
                return PlayerScore(
                    id: playerStats.id,
                    stats: playerStats,
                    game: .init(opponentName: opponentName, score: score),
                    score: calculateScore(from: playerStats)
                )
            }

            self.playersScores.append(contentsOf: playersScores)
            self.playersScores.sort(by: >)
            for (index, game) in games.enumerated() {
                guard let visitorTeamBestPick = self.playersScores.first(where: { $0.stats.player?.teamId == game.visitorTeam.id }),
                      let homeTeamBestPick = self.playersScores.first(where: { $0.stats.player?.teamId == game.homeTeam.id })
                else { continue }
                games[index].teamsBestsPicks = .init(
                    visitor: visitorTeamBestPick,
                    home: homeTeamBestPick
                )
            }
            guard let nextPageNumber = response.meta.nextPage else {
                isLoading = false
                if let player = myPick.player {
                    myPick = find(player, in: self.playersScores)
                }
                return
            }
            await fetchGamesStats(pageNumber: nextPageNumber)
        } catch {
            isLoading = false
            print(error)
        }
    }

    private func calculateScore(from playerStats: PlayerStats) -> Int {
        playerStats.points
        + playerStats.rebounds
        + playerStats.assists
        + playerStats.blocks
        + playerStats.steals
        + playerStats.fieldGoalsMade
        + playerStats.threePointsFieldGoalsMade
        + playerStats.freeThrowsMade
        - (playerStats.fieldGoalsAttempted - playerStats.fieldGoalsMade)
        - (playerStats.threePointsFieldGoalsAttempted - playerStats.threePointsFieldGoalsMade)
        - (playerStats.freeThrowsAttempted - playerStats.freeThrowsMade)
        - playerStats.turnovers
    }
    
    private func find(_ player: Player, in playersScores: [PlayerScore]) -> MyPick {
        guard let playerScore = playersScores.first(where: { $0.stats.player?.id == player.id }) else {
            return .picked(player)
        }
        return .score(playerScore)
    }
}

struct GamesList: View {
    @ObservedObject var model: GamesListModel
    
    init(model: GamesListModel) {
        self.model = model
        Task { await model.fetchGames() }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Form {
                    Section(header: Text("My pick")) {
                        switch model.myPick {
                        case .none:
                            Button(action: { model.myPickTapped() }) {
                                Text("Pick a player")
                            }
                        case let .picked(player):
                            HStack {
                                Image(player.team.name.lowercased())
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                Text(player.displayName)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onTapGesture { model.myPickTapped() }
                        case let .score(playerScore):
                            List {
                                PlayerScoreView(
                                    playerScore: playerScore,
                                    showTeamLogo: true,
                                    isMyPick: true
                                ) { model.playerDetailTapped(playerScore: playerScore) }
                                Button(action: { model.myPickTapped() }) {
                                    Text("Edit my pick")
                                }
                            }
                        }
                    }
                    if !model.playersScoresTopThree.isEmpty {
                        Section(header: Text("Top 3")) {
                            List {
                                ForEach(model.playersScoresTopThree) { playerScore in
                                    PlayerScoreView(
                                        playerScore: playerScore,
                                        showTeamLogo: true,
                                        isMyPick: model.myPick.playerScore?.id == playerScore.id
                                    ) { model.playerDetailTapped(playerScore: playerScore) }
                                }
                            }
                            Button(action: { model.viewTop25ButtonTapped() }) {
                                Text("View Top 25")
                            }
                        }
                    }
                    Section(header: Text("Games")) {
                        List {
                            ForEach(model.games) { game in
                                GameView(
                                    game: game,
                                    myPickPlayerScore: nil
                                )
                                .contentShape(Rectangle())
                                .onTapGesture(perform: { model.gameDetailTapped(game: game) })
                            }
                        }
                    }
                }
                .navigationTitle(dateFormatter.string(from: model.date))
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(dateFormatter.string(from: model.date.daysBefore(1))) {
                            model.previousDayButtonTapped()
                        }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(dateFormatter.string(from: model.date.daysAfter(1))) {
                            model.nextDayButtonTapped()
                        }
                    }
                }
                .navigationDestination(
                    unwrapping: $model.destination,
                    case: /GamesListModel.Destination.gameDetail
                ) { $gameDetailModel in
                    GameDetailView(model: gameDetailModel)
                }
                .navigationDestination(
                    unwrapping: $model.destination,
                    case: /GamesListModel.Destination.top25
                ) { $top25Model in
                    Top25View(model: top25Model)
                }
                .sheet(
                    unwrapping: $model.destination,
                    case: /GamesListModel.Destination.playerDetail
                ) { $playerScore in
                    PlayerDetailView(playerScore: playerScore) { model.playerDetailDismissed() }
                }
                .sheet(
                    unwrapping: $model.destination,
                    case: /GamesListModel.Destination.myPick
                ) { $myPickModel in
                    MyPickView(
                        model: myPickModel,
                        onClose: { model.myPickCloseButtonTapped() },
                        onPlayerPicked: { player in model.myPickPlayerPicked(player: player) }
                    )
                }
                .opacity(model.isLoading ? 0 : 1)
                .animation(.easeInOut(duration: 0.3), value: model.isLoading)
                .refreshable { await model.fetchGames() }
                ProgressView()
                .opacity(model.isLoading ? 1 : 0)
            }
        }
    }
}

struct GameView: View {
    let game: GameScore
    let myPickPlayerScore: PlayerScore?

    var body: some View {
        VStack(spacing: 4) {
            GameScoreView(game: game)
            if let teamsBestsPicks = game.teamsBestsPicks {
                HStack {
                    Text14("\(teamsBestsPicks.visitor.stats.player?.displayName ?? "Player Nil") : \(teamsBestsPicks.visitor.score)")
                    .bold()
                    .foregroundColor(myPickPlayerScore?.id == teamsBestsPicks.visitor.id ? .accentColor : .primary)
                    Spacer()
                    Text14("\(teamsBestsPicks.home.stats.player?.displayName ?? "Player Nil") : \(teamsBestsPicks.home.score)")
                    .bold()
                    .foregroundColor(myPickPlayerScore?.id == teamsBestsPicks.home.id ? .accentColor : .primary)
                }
            }
        }
    }
}

struct GameScoreView: View {
    let game: GameScore
    
    var body: some View {
        HStack(spacing: 0) {
            VStack {
                Image(game.visitorTeam.name.lowercased())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                Text14(game.visitorTeam.name)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            VStack(spacing: 4) {
                Text16("\(game.visitorTeam.score) - \(game.homeTeam.score)")
                Text16(format(status: game.status))
            }
            .frame(minWidth: 0, maxWidth: .infinity)
            VStack {
                Image(game.homeTeam.name.lowercased())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40)
                Text14(game.homeTeam.name)
            }
            .frame(minWidth: 0, maxWidth: .infinity)
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MMM d, yyyy"
    return formatter
}()

private func format(status: String) -> String {
    var formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    
    guard let date = formatter.date(from: status) else {
        return status
    }
    formatter = DateFormatter()
    formatter.dateFormat = "HH:mm a"
    return formatter.string(from: date)
}

#Preview {
    GamesList(model: .init(date: Date.now))
}
