//
//  HomeView.swift
//  LangwithFootball
//
//  Created by Andrew Yuzgin on 03/04/2025.
//

import SwiftUI
import MapKit
import UIKit

struct HomeView: View {
    @StateObject private var fixtureViewModel = FixtureViewModel()
    @StateObject private var matchViewModel = MatchViewModel()
    @State private var currentDate = Date()
    @State private var showingMapOptions = false
    @State private var announcementsExpanded = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Welcome Header
                welcomeHeader
                
                // Announcements Section
                announcementsSection
                
                // Training Time Section
                trainingTimeSection
                
                // Next Fixtures Section
                nextFixturesSection
                
                // Recent Results Section
                recentResultsSection
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .onAppear {
            fixtureViewModel.fetchFixtures()
            matchViewModel.fetchMatches()
        }
        .actionSheet(isPresented: $showingMapOptions) {
            ActionSheet(
                title: Text("Open in Maps"),
                message: Text("Choose which map app to use"),
                buttons: [
                    .default(Text("Apple Maps")) {
                        openInAppleMaps()
                    },
                    .default(Text("Google Maps")) {
                        openInGoogleMaps()
                    },
                    .cancel()
                ]
            )
        }
    }
    
    // MARK: - Welcome Header
    private var welcomeHeader: some View {
        VStack(spacing: 8) {
            Text("Welcome to Langwith Football!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
            
            Text("Stay updated with the latest news and fixtures")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 16)
    }
    
    // MARK: - Announcements Section
    private var announcementsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionHeader(title: "📢 Announcements", icon: "megaphone.fill")
                
                Spacer()
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        announcementsExpanded.toggle()
                    }
                }) {
                    Image(systemName: announcementsExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .padding(4)
                }
            }
            
            let announcements = [
                ("Welcome to the new Langwith Football app!", "Explore fixtures, results, fantasy, and more — all in one place.", true),
                ("Trials announced", "Trials are set for 2–4 PM on Tue 16 Sep at the 22 Acres.", true),
                ("Training confirmed", "Training is confirmed for the dates, times, and location shown below.", false)
            ]
            
            VStack(spacing: 8) {
                ForEach(Array(announcements.enumerated()), id: \.offset) { index, announcement in
                    if index == 0 || announcementsExpanded {
                        announcementCard(
                            title: announcement.0,
                            message: announcement.1,
                            isImportant: announcement.2,
                            isCollapsed: !announcementsExpanded && index == 0
                        )
                        .scaleEffect(announcementsExpanded ? 1.0 : (index == 0 ? 1.0 : 0.95))
                        .opacity(announcementsExpanded ? 1.0 : (index == 0 ? 1.0 : 0.8))
                    }
                }
            }
        }
    }
    
    // MARK: - Training Time Section
    private var trainingTimeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "⚽ Training Schedule", icon: "calendar")
            
            VStack(spacing: 8) {
                trainingCard(
                    day: "Tuesday",
                    time: "3:00 PM - 4:00 PM",
                    location: "3G at York Sport Village"
                )
            }
        }
    }
    
    // MARK: - Next Fixtures Section
    private var nextFixturesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "📅 Upcoming Fixtures", icon: "calendar.badge.clock")
            
            if fixtureViewModel.isLoading {
                loadingCard(message: "Loading fixtures...")
            } else if fixtureViewModel.hasLoaded {
                let nextDayFixtures = getNextDayFixtures()
                if nextDayFixtures.isEmpty {
                    noDataCard(message: "No upcoming fixtures")
                } else {
                    ForEach(nextDayFixtures) { fixture in
                        fixtureCard(fixture: fixture)
                    }
                }
            } else {
                loadingCard(message: "Loading fixtures...")
            }
        }
    }
    
    // MARK: - Recent Results Section
    private var recentResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "🏆 Recent Results", icon: "trophy.fill")
            
            if matchViewModel.isLoading {
                loadingCard(message: "Loading results...")
            } else if matchViewModel.hasLoaded {
                let recentDayResults = getRecentDayResults()
                if recentDayResults.isEmpty {
                    noDataCard(message: "No recent results")
                } else {
                    ForEach(recentDayResults) { match in
                        resultCard(match: match)
                    }
                }
            } else {
                loadingCard(message: "Loading results...")
            }
        }
    }
    
    // MARK: - Helper Views
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.orange)
                .font(.title3)
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.9))
            Spacer()
        }
    }
    
    private func announcementCard(title: String, message: String, isImportant: Bool, isCollapsed: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.black.opacity(0.9))
                
                if isImportant {
                    Spacer()
                    Text("IMPORTANT")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .cornerRadius(4)
                }
            }
            
            if !isCollapsed {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.7))
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(12)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.white.opacity(0.95), Color.white.opacity(0.85)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .white.opacity(0.4), radius: 6, x: 0, y: -3)
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
    }
    
    private func trainingCard(day: String, time: String, location: String) -> some View {
        Button(action: {
            showingMapOptions = true
        }) {
            VStack(spacing: 8) {
                HStack {
                    Text(day)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "sportscourt")
                        .foregroundColor(.orange)
                        .font(.title2)
                        .frame(width: 22, height: 22)
                }
                
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(.orange)
                        .font(.caption)
                    Text(time)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .scaleEffect(0.9)
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "location")
                        .foregroundColor(.orange)
                        .font(.caption)
                    Text(location)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .scaleEffect(0.9)
                    Spacer()
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemGray6), Color(.systemGray5)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 12))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.primary.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: .white.opacity(0.3), radius: 8, x: 0, y: -2)
            .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
            .padding(.vertical, 6)
            .padding(.horizontal, 12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func fixtureCard(fixture: Fixture) -> some View {
        FixtureCard(fixture: fixture)
    }
    
    private func resultCard(match: Match) -> some View {
        ResultCard(match: match)
    }
    
    private func loadingCard(message: String) -> some View {
        HStack {
            ProgressView()
                .scaleEffect(0.8)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.black.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.white.opacity(0.9))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func noDataCard(message: String) -> some View {
        HStack {
            Image(systemName: "info.circle")
                .foregroundColor(.orange)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.black.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.white.opacity(0.9))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    // MARK: - Helper Functions
    private func getNextDayFixtures() -> [Fixture] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: currentDate)
        
        // Find the next day with fixtures
        for dayOffset in 0...30 { // Check today and next 30 days
            let checkDate = calendar.date(byAdding: .day, value: dayOffset, to: today)!
            let dayFixtures = fixtureViewModel.fixtures.filter { fixture in
                calendar.isDate(fixture.date, inSameDayAs: checkDate)
            }
            
            if !dayFixtures.isEmpty {
                return dayFixtures.sorted { (fixture1: Fixture, fixture2: Fixture) in
                    fixture1.time < fixture2.time
                }
            }
        }
        return []
    }
    
    private func getRecentDayResults() -> [Match] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: currentDate)
        
        // Find the most recent day with results
        for dayOffset in 0...30 { // Check last 30 days including today
            let checkDate = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let dayResults = matchViewModel.matches.filter { match in
                calendar.isDate(match.date, inSameDayAs: checkDate)
            }
            if !dayResults.isEmpty {
                return dayResults.sorted { (match1: Match, match2: Match) in
                    match1.date < match2.date
                }
            }
        }
        return []
    }
    
    
    private func openInAppleMaps() {
        let coordinate = CLLocationCoordinate2D(latitude: 53.951702, longitude: -1.016212)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "3G at York Sport Village"
        
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsMapTypeKey: MKMapType.standard.rawValue,
            MKLaunchOptionsShowsTrafficKey: false
        ])
    }
    
    private func openInGoogleMaps() {
        let latitude = 53.951702
        let longitude = -1.016212
        
        if let url = URL(string: "comgooglemaps://?q=\(latitude),\(longitude)&zoom=14&views=traffic") {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            } else {
                // Fallback to web version if Google Maps app is not installed
                if let webUrl = URL(string: "https://www.google.com/maps?q=\(latitude),\(longitude)") {
                    UIApplication.shared.open(webUrl)
                }
            }
        }
    }
}
