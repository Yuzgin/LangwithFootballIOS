//
//  PlayerIconView.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 29/05/2025.
//

import SwiftUI

struct PlayerIconView: View {
    let player: Player

    var body: some View {
        VStack(spacing: 0) {
            // Player icon
            Image(player.position == "Goalkeeper" ? "PlayerIconGK" : "PlayerIcon")
                .resizable()
                .interpolation(.low)
                .scaledToFit()
                .frame(width: 55, height: 55)
                .clipShape(Circle())
                .padding(.top, 6)
                .padding(.bottom, 6)

            // Full-width white strip for name
            Text(player.name)
                .font(.caption2.weight(.semibold))
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .foregroundColor(.black) // text readable on white
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
                .background(Color.white) // solid strip
        }
        .frame(width: 65)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.4))
        )
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(player.name)
    }
}

