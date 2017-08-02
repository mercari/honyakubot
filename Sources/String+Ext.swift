//
//  String+Ext.swift
//  honyakubot
//
//  Created by teddy on 2017/08/02.
//
//

import Foundation
import AppKit

extension String {
    func convertHtmlSymbols() -> String? {
        guard let data = data(using: .utf8) else { return nil }
        return try? NSAttributedString(data: data, options: [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: String.Encoding.utf8.rawValue
            ], documentAttributes: nil).string
    }
}
