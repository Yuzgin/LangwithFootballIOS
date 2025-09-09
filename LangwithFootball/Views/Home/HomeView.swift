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
            sectionHeader(title: "📢 Announcements", icon: "megaphone.fill")
            
            VStack(spacing: 8) {
                announcementCard(
                    title: "New Season Starting Soon!",
                    message: "The 2025 season kicks off next week. Make sure your fantasy team is ready!",
                    isImportant: true
                )
                
                announcementCard(
                    title: "Training Schedule Updated",
                    message: "Tuesday and Thursday training sessions now start at 6:30 PM",
                    isImportant: false
                )
                
                announcementCard(
                    title: "Fantasy League Registration",
                    message: "Join the Langwith Fantasy League - prizes for top performers!",
                    isImportant: false
                )
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
            sectionHeader(title: "📅 Next Fixtures", icon: "calendar.badge.clock")
            
            if fixtureViewModel.fixtures.isEmpty {
                loadingCard(message: "Loading fixtures...")
            } else {
                let nextDayFixtures = getNextDayFixtures()
                if nextDayFixtures.isEmpty {
                    noDataCard(message: "No upcoming fixtures")
                } else {
                    ForEach(nextDayFixtures) { fixture in
                        fixtureCard(fixture: fixture)
                    }
                }
            }
        }
    }
    
    // MARK: - Recent Results Section
    private var recentResultsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(title: "🏆 Recent Results", icon: "trophy.fill")
            
            if matchViewModel.matches.isEmpty {
                loadingCard(message: "Loading results...")
            } else {
                let recentDayResults = getRecentDayResults()
                if recentDayResults.isEmpty {
                    noDataCard(message: "No recent results")
                } else {
                    ForEach(recentDayResults) { match in
                        resultCard(match: match)
                    }
                }
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
    
    private func announcementCard(title: String, message: String, isImportant: Bool) -> some View {
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
            
            Text(message)
                .font(.caption)
                .foregroundColor(.black.opacity(0.7))
                .multilineTextAlignment(.leading)
        }
        .padding(12)
        .background(Color.white.opacity(0.9))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func trainingCard(day: String, time: String, location: String) -> some View {
        Button(action: {
            showingMapOptions = true
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(day)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.black.opacity(0.9))
                    
                    Text(time)
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.7))
                    
                    Text(location)
                        .font(.caption)
                        .foregroundColor(.black.opacity(0.6))
                }
                
                Spacer()
                
                Image(systemName: "sportscourt")
                    .foregroundColor(.orange)
                    .font(.title2)
            }
            .padding(12)
            .background(Color.white.opacity(0.9))
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func fixtureCard(fixture: Fixture) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(formatDate(fixture.date))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
                
                Spacer()
                
                Text(formatTime(fixture.time))
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.7))
            }
            
            HStack {
                Text(fixture.team1)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.black.opacity(0.9))
                
                Text("vs")
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.6))
                
                Text(fixture.team2)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.black.opacity(0.9))
            }
            
            HStack {
                Image(systemName: "location")
                    .foregroundColor(.orange)
                    .font(.caption)
                Text(fixture.location)
                    .font(.caption)
                    .foregroundColor(.black.opacity(0.7))
                Spacer()
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.9))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
    
    private func resultCard(match: Match) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(formatDate(match.date))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                
                Spacer()
            }
            
            HStack {
                Text(match.team1)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.black.opacity(0.9))
                
                Spacer()
                
                Text("\(match.team1Score) - \(match.team2Score)")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.black.opacity(0.9))
                
                Spacer()
                
                Text(match.team2)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.black.opacity(0.9))
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.9))
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
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
        for dayOffset in 0...7 { // Check last 7 days including today
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
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
    
    private func formatTime(_ time: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: time)
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
        let locationName = "3G at York Sport Village"
        
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
