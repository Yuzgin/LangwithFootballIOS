//
//  LangwithTeam.swift
//  LangwithFootball
//
//  Created by Main on 04/09/2025.
//


//
//  LangwithTeam.swift
//  LangwithFootball
//

import Foundation

enum LangwithTeam: String, CaseIterable, Identifiable {
    case one = "Langwith 1s"
    case two = "Langwith 2s"
    case three = "Langwith 3s"
    case four = "Langwith 4s"
    case five = "Langwith 5s"
    case six = "Langwith 6s"

    var id: String { rawValue }
}
