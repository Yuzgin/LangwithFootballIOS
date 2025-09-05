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
        VStack(spacing: 6) {
            Image(player.position == "Goalkeeper" ? "PlayerIconGK" : "PlayerIcon")
                .resizable()
                .interpolation(.low) // cheaper scaling
                .scaledToFit()
                .frame(width: 55, height: 55) // a touch smaller than before
                .clipShape(Circle())

            Text(player.name)
                .font(.caption2.weight(.semibold))
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .foregroundStyle(.white)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .frame(width: 65) // compact card width
        .background(
            // Solid, GPU-friendly background (no blur)
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.black.opacity(0.4))
        )
        // Removed stroke & shadow to avoid extra offscreen renders
        .accessibilityElement(children: .combine)
        .accessibilityLabel(player.name)
    }
}

