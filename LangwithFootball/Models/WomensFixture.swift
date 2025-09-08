import Foundation

struct WomensFixture: Identifiable, Codable {
    let id: Int
    let team1: String
    let team2: String
    let location: String
    let date: Date
    let time: Date

    enum CodingKeys: String, CodingKey {
        case id, team1, team2, location, date, time
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        team1 = try container.decode(String.self, forKey: .team1)
        team2 = try container.decode(String.self, forKey: .team2)
        location = try container.decode(String.self, forKey: .location)
        let dateStr = try container.decode(String.self, forKey: .date)
        let timeStr = try container.decode(String.self, forKey: .time)
        guard let d = WomensFixture.dateFormatter.date(from: dateStr) else {
            throw DecodingError.dataCorruptedError(forKey: .date, in: container, debugDescription: "Expected yyyy-MM-dd")
        }
        let t = WomensFixture.timeFormatterSeconds.date(from: timeStr) ?? WomensFixture.timeFormatterMinutes.date(from: timeStr)
        guard let tParsed = t else {
            throw DecodingError.dataCorruptedError(forKey: .time, in: container, debugDescription: "Expected HH:mm[:ss]")
        }
        date = d
        time = tParsed
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_GB")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd"
        return f
    }()

    private static let timeFormatterSeconds: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_GB")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "HH:mm:ss"
        return f
    }()

    private static let timeFormatterMinutes: DateFormatter = {
        let f = DateFormatter()
        f.calendar = Calendar(identifier: .gregorian)
        f.locale = Locale(identifier: "en_GB")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "HH:mm"
        return f
    }()
}
