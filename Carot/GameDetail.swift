//
//  GameDetail.swift
//  Carot
//
//  Created by David Bou on 17/01/2024.
//

import SwiftUI
import SwiftUINavigation

@MainActor
final class GameDetailModel: ObservableObject {
    enum Destination: Equatable {
        case playerDetail(PlayerScore)
    }
    
    let game: GameScore
    let visitorTeamPlayersScores: [PlayerScore]
    let homeTeamPlayersScores: [PlayerScore]
    let myPickPlayerScore: PlayerScore?
    @Published var destination: Destination? = nil
    
    init(
        game: GameScore,
        visitorTeamPlayersScores: [PlayerScore],
        homeTeamPlayersScores: [PlayerScore],
        myPickPlayerScore: PlayerScore?
    ) {
        self.game = game
        self.visitorTeamPlayersScores = visitorTeamPlayersScores
        self.homeTeamPlayersScores = homeTeamPlayersScores
        self.myPickPlayerScore = myPickPlayerScore
    }
    
    func playerDetailTapped(playerScore: PlayerScore) -> Void {
        destination = .playerDetail(playerScore)
    }
    
    func playerDetailDismissed() -> Void {
        destination = nil
    }
}

struct GameDetailView: View {
    @ObservedObject var model: GameDetailModel
    
    var body: some View {
        Form {
            Section {
                GameScoreView(game: model.game)
            }
            Section(model.game.visitorTeam.name) {
                ForEach(model.visitorTeamPlayersScores) { playerScore in
                    PlayerScoreView(
                        playerScore: playerScore,
                        showTeamLogo: false,
                        isMyPick: model.myPickPlayerScore?.id == playerScore.id
                    ) { model.playerDetailTapped(playerScore: playerScore) }
                }
            }
            Section(model.game.homeTeam.name) {
                ForEach(model.homeTeamPlayersScores) { playerScore in
                    PlayerScoreView(
                        playerScore: playerScore,
                        showTeamLogo: false,
                        isMyPick: model.myPickPlayerScore?.id == playerScore.id
                    ) { model.playerDetailTapped(playerScore: playerScore) }
                }
            }
        }
        .sheet(
            unwrapping: $model.destination,
            case: /GameDetailModel.Destination.playerDetail
        ) { $playerScore in
            PlayerDetailView(playerScore: playerScore) { model.playerDetailDismissed() }
        }
    }
}

#Preview {
    GameDetailView(model: .init(
        game: .mock,
        visitorTeamPlayersScores: [.mock, .mock],
        homeTeamPlayersScores: [.mock, .mock],
        myPickPlayerScore: nil
    ))
}
