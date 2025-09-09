//
//  ContentView.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 03/04/2025.
//

import SwiftUI

let types: [String] = ["Home", "Fantasy", "Fixtures", "Results", "Settings"]

struct ContentView: View {

    @EnvironmentObject var appState: AppState
    @State private var selectedType: String = types.first!
    @Namespace private var animation

    /// How much extra header height to show *below* the sticky tab bar
    private let extraHeaderHeight: CGFloat = 170

    @ViewBuilder
    func selectedContentView(for type: String) -> some View {
        switch type {
        case "Home":
            HomeView()
        case "Fantasy":
            FantasyView()
        case "Fixtures":
            FixturesView()
        case "Results":
            ResultsView()
        case "Settings":
            SettingsView()
        default:
            Text("Unknown View")
        }
    }

    var body: some View {
        ZStack {
            // GLOBAL BACKGROUND COLOR
            LinearGradient(
                colors: [Color.black, Color(red: 0.2, green: 0.15, blue: 0.0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ResizableHeaderScrollView {
                VStack(spacing: 6) {
                    // TITLE
                    HStack {
                        Spacer()
                        Text("Langwith Football")
                            .font(.title)
                            .fontWeight(.heavy)
                            .foregroundStyle(.black.opacity(0.9))
                            .shadow(color: .white.opacity(0.3), radius: 2, x: 0, y: 1)
                        Spacer()
                    }
                    .padding(.top, 15)
                    .padding(.bottom, 8)

                    // DIVIDER for readability
                    Divider()
                        .background(Color.black.opacity(0.2))
                        .padding(.horizontal, 15)
                }

            } stickyHeader: {
                // HORIZONTAL TABS
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(types, id: \.self) { type in
                            Text(type)
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 20)
                                .frame(height: 32)
                                .background {
                                    if selectedType == type {
                                        Capsule()
                                            .fill(Color.white.opacity(0.95))
                                            .matchedGeometryEffect(id: "ACTIVETAB", in: animation)
                                    }
                                }
                                .foregroundStyle(
                                    selectedType == type
                                        ? .black
                                        : .black.opacity(0.7)
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.snappy) {
                                        selectedType = type
                                    }
                                }
                        }
                    }
                }
                .safeAreaPadding(.horizontal, 15)
                .padding(.vertical, 6)

            } background: {
                // FULL HEADER BACKGROUND
                VStack(spacing: 0) {
                    LinearGradient(
                        colors: [Color.yellow, Color.orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    // Extra header height beneath tabs
                    Color.clear
                        .frame(height: extraHeaderHeight)
                        .background(
                            LinearGradient(
                                colors: [Color.yellow, Color.orange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .overlay(alignment: .bottom) {
                    Divider()
                        .background(Color.black.opacity(0.15))
                }

            } content: {
                selectedContentView(for: selectedType)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState())
}

