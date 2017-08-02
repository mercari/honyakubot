//
//  GoogleTranslateResponse.swift
//  honyakubot
//
//  Created by teddy on 2017/06/30.
//
//

import Foundation

struct GoogleTranslateResponse {
    struct Translation {
        let translatedText: String
        let detectedSourceLanguage: String?

        init(dict: [String: Any]) {
            guard let translatedText = dict["translatedText"] as? String else {
                self.translatedText = ""
                self.detectedSourceLanguage = nil
                return
            }
            self.translatedText = translatedText.convertHtmlSymbols() ?? ""
            self.detectedSourceLanguage = dict["detectedSourceLanguage"] as? String
        }
    }

    let translations: [Translation]

    init(dict: [String: Any]) {
        guard
            let data = dict["data"] as? [String: Any],
            let translationDictsArray = data["translations"] as? [[String: Any]] else {
                self.translations = []
                return
        }
        self.translations = translationDictsArray.map(Translation.init)
    }
}

