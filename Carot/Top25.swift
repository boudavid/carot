//
//  Top25.swift
//  Carot
//
//  Created by David Bou on 17/01/2024.
//

import SwiftUI
import SwiftUINavigation

@MainActor
final class Top25Model: ObservableObject {
    enum Destination: Equatable {
        case playerDetail(PlayerScore)
    }
    
    let playersScores: [PlayerScore]
    let myPickPlayerScore: PlayerScore?
    @Published var destination: Destination? = nil
    
    init(playersScores: [PlayerScore], myPickPlayerScore: PlayerScore?) {
        self.playersScores = playersScores
        self.myPickPlayerScore = myPickPlayerScore
    }
    
    func playerDetailTapped(playerScore: PlayerScore) -> Void {
        destination = .playerDetail(playerScore)
    }
    
    func playerDetailDismissed() -> Void {
        destination = nil
    }
}

struct Top25View: View {
    @ObservedObject var model: Top25Model
    
    var body: some View {
        List {
            ForEach(model.playersScores) { playerScore in
                PlayerScoreView(
                    playerScore: playerScore,
                    showTeamLogo: true,
                    isMyPick: model.myPickPlayerScore?.id == playerScore.id
                ) { model.playerDetailTapped(playerScore: playerScore) }
            }
        }
        .navigationTitle("Top 25")
        .sheet(
            unwrapping: $model.destination,
            case: /Top25Model.Destination.playerDetail
        ) { $playerScore in
            PlayerDetailView(playerScore: playerScore) { model.playerDetailDismissed() }
        }
    }
}
