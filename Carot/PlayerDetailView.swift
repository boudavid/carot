//
//  PlayerDetailView.swift
//  Carot
//
//  Created by David Bou on 17/01/2024.
//

import SwiftUI

struct PlayerDetailView: View {
    let playerScore: PlayerScore
    let onClose: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    Section {
                        VStack(spacing: 12) {
                            HStack {
                                Spacer()
                                ZStack {
                                    Image(playerScore.stats.team.name.lowercased())
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 200, height: 200)
                                    Circle()
                                    .strokeBorder(.black, lineWidth: 2)
                                    .background(Circle().fill(.white))
                                    .frame(width: 120, height: 120)
                                    .shadow(radius: 10)
                                    .opacity(0.9)
                                    Text50("\(playerScore.score)")
                                    .foregroundColor(.black)
                                    .bold()
                                }
                                Spacer()
                            }
                            HStack {
                                PlayerInfoView(title: "Position", subTitle: playerScore.stats.player?.position ?? "Player Nil")
                                .frame(minWidth: 0, maxWidth: .infinity)
                                PlayerInfoView(title: "Minutes", subTitle: playerScore.stats.minutes)
                                .frame(minWidth: 0, maxWidth: .infinity)
                                PlayerInfoView(title: "Fouls", subTitle: "\(playerScore.stats.personalFouls)")
                                .frame(minWidth: 0, maxWidth: .infinity)
                            }
                        }
                    }
                    Section("Game") {
                        VStack {
                            HStack {
                                Text("Opponent")
                                .frame(minWidth: 0, maxWidth: .infinity)
                                Text("Score")
                                .frame(minWidth: 0, maxWidth: .infinity)
                            }
                            HStack {
                                HStack {
                                    Image(playerScore.game.opponentName.lowercased())
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30)
                                    Text(playerScore.game.opponentName)
                                }
                                .frame(minWidth: 0, maxWidth: .infinity)
                                Text(playerScore.game.score)
                                .frame(minWidth: 0, maxWidth: .infinity)
                            }
                        }
                    }
                    Section("Score detail") {
                        StatView(key: "Points", value: "\(playerScore.stats.points)", points: playerScore.stats.points)
                        StatView(key: "Rebounds", value: "\(playerScore.stats.rebounds)", points: playerScore.stats.rebounds)
                        StatView(key: "Assists", value: "\(playerScore.stats.assists)", points: playerScore.stats.assists)
                        StatView(key: "Steals", value: "\(playerScore.stats.steals)", points: playerScore.stats.steals)
                        StatView(key: "Blocks", value: "\(playerScore.stats.blocks)", points: playerScore.stats.blocks)
                        StatView(
                            key: "Field goals",
                            value: "\(playerScore.stats.fieldGoalsMade) / \(playerScore.stats.fieldGoalsAttempted)",
                            points: playerScore.stats.fieldGoalsMade - (playerScore.stats.fieldGoalsAttempted - playerScore.stats.fieldGoalsMade)
                        )
                        StatView(
                            key: "3 pts",
                            value: "\(playerScore.stats.threePointsFieldGoalsMade) / \(playerScore.stats.threePointsFieldGoalsAttempted)",
                            points: playerScore.stats.threePointsFieldGoalsMade - (playerScore.stats.threePointsFieldGoalsAttempted - playerScore.stats.threePointsFieldGoalsMade)
                        )
                        StatView(
                            key: "Free throws",
                            value: "\(playerScore.stats.freeThrowsMade) / \(playerScore.stats.freeThrowsAttempted)",
                            points: playerScore.stats.freeThrowsMade - (playerScore.stats.freeThrowsAttempted - playerScore.stats.freeThrowsMade)
                        )
                        StatView(key: "Turnovers", value: "\(playerScore.stats.turnovers)", points: -playerScore.stats.turnovers)
                        StatView(key: "", value: "Total", points: playerScore.score)
                    }
                }
                .navigationTitle("\(playerScore.stats.player?.displayName ?? "Player Nil")")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") { onClose() }
                    }
                }
            }
        }
    }
}

struct StatView: View {
    let key: String
    let value: String
    let points: Int
    private var pointsColor: Color {
        points >= 0 ? .green : .red
    }
    
    var body: some View {
        HStack {
            Text(key)
            .frame(minWidth: 0, maxWidth: .infinity)
            Text(value)
            .frame(minWidth: 0, maxWidth: .infinity)
            Text("\(points)")
            .foregroundColor(pointsColor)
            .frame(minWidth: 0, maxWidth: .infinity)
        }
    }
}

struct PlayerInfoView: View {
    let title: String
    let subTitle: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
            Text(subTitle)
        }
    }
}

#Preview {
    PlayerDetailView(playerScore: .mock) { print("Close") }
}
