//  Fixture.swift
//  LangwithFootball

import Foundation

struct Fixture: Identifiable, Codable, Equatable {
    let id: Int
    let date: Date       // parsed from "yyyy-MM-dd"
    let time: Date       // parsed from "HH:mm:ss" (anchored to a reference date)
    let team1: String
    let team2: String
    let gameWeek: Int?
    let location: String

    enum CodingKeys: String, CodingKey {
        case id, date, time, team1, team2, location
        case gameWeek = "game_week"
    }

    // MARK: - Custom decoding to handle separate date/time strings
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id        = try c.decode(Int.self,    forKey: .id)
        team1     = try c.decode(String.self, forKey: .team1)
        team2     = try c.decode(String.self, forKey: .team2)
        location  = try c.decode(String.self, forKey: .location)
        gameWeek  = try c.decodeIfPresent(Int.self, forKey: .gameWeek)

        let dateStr = try c.decode(String.self, forKey: .date)   // "2025-02-19"
        let timeStr = try c.decode(String.self, forKey: .time)   // "12:00:00"

        guard let d = Fixture.dateFormatter.date(from: dateStr) else {
            throw DecodingError.dataCorruptedError(forKey: .date, in: c,
                debugDescription: "Expected yyyy-MM-dd, got \(dateStr)")
        }
        // Accept "HH:mm:ss" or "HH:mm"
        let t: Date? =
            Fixture.timeFormatterSeconds.date(from: timeStr) ??
            Fixture.timeFormatterMinutes.date(from: timeStr)

        guard let tParsed = t else {
            throw DecodingError.dataCorruptedError(forKey: .time, in: c,
                debugDescription: "Expected HH:mm[:ss], got \(timeStr)")
        }

        date = d
        time = tParsed
    }

    // MARK: - Formatters
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale   = Locale(identifier: "en_GB")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private static let timeFormatterSeconds: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale   = Locale(identifier: "en_GB")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "HH:mm:ss"
        return f
    }()

    private static let timeFormatterMinutes: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale   = Locale(identifier: "en_GB")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "HH:mm"
        return f
    }()
}

// If you don't actually use this wrapper, you can delete it.
struct FixtureResponse: Codable {
    let fixtures: [Fixture]
}

