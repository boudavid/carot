//
//  PlayerScoreView.swift
//  Carot
//
//  Created by David Bou on 17/01/2024.
//

import SwiftUI

struct PlayerScoreView: View {
    let playerScore: PlayerScore
    let showTeamLogo: Bool
    let isMyPick: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            if showTeamLogo {
                Image(playerScore.stats.team.name.lowercased())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
            }
            Text(playerScore.stats.player?.displayName ?? "Player Nil")
            .foregroundColor(isMyPick ? .accentColor : .primary)
            Spacer()
            Text("\(playerScore.score)")
            .foregroundColor(isMyPick ? .accentColor : .primary)
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}

#Preview {
    PlayerScoreView(
        playerScore: .mock,
        showTeamLogo: false,
        isMyPick: false
    ) {
        print("Close")
    }
}
