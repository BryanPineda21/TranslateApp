//
//  TranslateModel.swift
//  Translate
//
//  Created by Bryan Pineda on 4/5/24.
//


// Define structs representing the JSON response
import Foundation

struct TranslationResponse: Codable {
    let responseData: ResponseData
    let quotaFinished: Bool
    let mtLangSupported: [String]?
    let responseDetails: String
    let responseStatus: Int
    let matches: [TranslationMatch]
    
    enum CodingKeys: String, CodingKey {
        case responseData = "responseData"
        case quotaFinished = "quotaFinished"
        case mtLangSupported = "mtLangSupported"
        case responseDetails = "responseDetails"
        case responseStatus = "responseStatus"
        case matches = "matches"
    }
}

struct ResponseData: Codable {
    let translatedText: String
    
    enum CodingKeys: String, CodingKey {
        case translatedText = "translatedText"
    }
}

struct TranslationMatch: Codable {
    let segment: String
    let translation: String
}

struct TranslationEntry: Identifiable {
    let id: String
    let originalText: String
    let translatedText: String
    let timestamp: Date
}

struct Language : Hashable{
    let name: String
    let code: String
}

let supportedLanguages: [Language] = [
    Language(name: "English", code: "en"),
    Language(name: "Spanish", code: "es"),
    Language(name: "French", code: "fr"),
    Language(name: "German", code: "de"),
    // Add more languages as needed
]
