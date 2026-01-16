//
//  RSSParser.swift
//  totem
//
//  Created by Totem Team on 1/16/26.
//

import Foundation

final class RSSParser: NSObject {
    private var currentElement = ""
    private var currentTitle = ""
    private var currentDescription = ""
    private var currentLink = ""
    private var currentPubDate = ""
    private var currentImageURL = ""
    private var currentAuthor = ""
    private var currentContent = ""

    private var items: [RSSItem] = []
    private var isInsideItem = false

    struct RSSItem {
        let title: String
        let description: String
        let link: String
        let pubDate: String
        let imageURL: String?
        let author: String?
        let content: String?
    }

    func parse(data: Data) throws -> [RSSItem] {
        items = []
        resetCurrentItem()

        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()

        if let error = parser.parserError {
            throw RSSError.parsingFailed(error.localizedDescription)
        }

        return items
    }

    func fetchAndParse(from urlString: String) async throws -> [RSSItem] {
        guard let url = URL(string: urlString) else {
            throw RSSError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw RSSError.networkError
        }

        return try parse(data: data)
    }

    private func resetCurrentItem() {
        currentTitle = ""
        currentDescription = ""
        currentLink = ""
        currentPubDate = ""
        currentImageURL = ""
        currentAuthor = ""
        currentContent = ""
    }

    private func cleanHTML(_ html: String) -> String {
        var clean = html.replacingOccurrences(
            of: "<[^>]+>",
            with: "",
            options: .regularExpression
        )
        // Named entities
        clean = clean.replacingOccurrences(of: "&amp;", with: "&")
        clean = clean.replacingOccurrences(of: "&lt;", with: "<")
        clean = clean.replacingOccurrences(of: "&gt;", with: ">")
        clean = clean.replacingOccurrences(of: "&quot;", with: "\"")
        clean = clean.replacingOccurrences(of: "&#39;", with: "'")
        clean = clean.replacingOccurrences(of: "&nbsp;", with: " ")
        clean = clean.replacingOccurrences(of: "&apos;", with: "'")
        clean = clean.replacingOccurrences(of: "&hellip;", with: "…")
        clean = clean.replacingOccurrences(of: "&mdash;", with: "—")
        clean = clean.replacingOccurrences(of: "&ndash;", with: "–")
        clean = clean.replacingOccurrences(of: "&lsquo;", with: "'")
        clean = clean.replacingOccurrences(of: "&rsquo;", with: "'")
        clean = clean.replacingOccurrences(of: "&ldquo;", with: "\u{201C}")
        clean = clean.replacingOccurrences(of: "&rdquo;", with: "\u{201D}")
        // Common numeric entities
        clean = clean.replacingOccurrences(of: "&#8230;", with: "…")
        clean = clean.replacingOccurrences(of: "&#8217;", with: "'")
        clean = clean.replacingOccurrences(of: "&#8216;", with: "'")
        clean = clean.replacingOccurrences(of: "&#8220;", with: "\u{201C}")
        clean = clean.replacingOccurrences(of: "&#8221;", with: "\u{201D}")
        clean = clean.replacingOccurrences(of: "&#8211;", with: "–")
        clean = clean.replacingOccurrences(of: "&#8212;", with: "—")
        clean = clean.replacingOccurrences(of: "&#160;", with: " ")
        // Decode any remaining numeric entities
        clean = decodeNumericEntities(clean)
        return clean.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func decodeNumericEntities(_ string: String) -> String {
        var result = string
        let pattern = "&#(\\d+);"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return string }

        let range = NSRange(string.startIndex..., in: string)
        let matches = regex.matches(in: string, range: range).reversed()

        for match in matches {
            guard let codeRange = Range(match.range(at: 1), in: result),
                  let code = Int(result[codeRange]),
                  let scalar = Unicode.Scalar(code) else { continue }

            let char = String(Character(scalar))
            if let fullRange = Range(match.range, in: result) {
                result.replaceSubrange(fullRange, with: char)
            }
        }
        return result
    }

    private func extractImageFromContent() -> String? {
        let patterns = [
            "src=\"([^\"]+\\.(jpg|jpeg|png|gif|webp)[^\"]*)\"",
            "src='([^']+\\.(jpg|jpeg|png|gif|webp)[^']*)'",
        ]

        let textToSearch = currentContent.isEmpty ? currentDescription : currentContent

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(
                   in: textToSearch,
                   options: [],
                   range: NSRange(textToSearch.startIndex..., in: textToSearch)
               ),
               let range = Range(match.range(at: 1), in: textToSearch) {
                return String(textToSearch[range])
            }
        }

        return nil
    }
}

// MARK: - XMLParserDelegate
extension RSSParser: XMLParserDelegate {
    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        currentElement = elementName

        if elementName == "item" || elementName == "entry" {
            isInsideItem = true
            resetCurrentItem()
        }

        // Handle media:content or enclosure for images
        if isInsideItem {
            if elementName == "media:content" || elementName == "media:thumbnail" {
                if let url = attributeDict["url"] {
                    currentImageURL = url
                }
            } else if elementName == "enclosure" {
                if let url = attributeDict["url"],
                   attributeDict["type"]?.hasPrefix("image") == true {
                    currentImageURL = url
                }
            }
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, isInsideItem else { return }

        switch currentElement {
        case "title":
            currentTitle += trimmed
        case "description", "summary":
            currentDescription += trimmed
        case "link":
            currentLink += trimmed
        case "pubDate", "published", "updated":
            currentPubDate += trimmed
        case "dc:creator", "author":
            currentAuthor += trimmed
        case "content:encoded", "content":
            currentContent += trimmed
        default:
            break
        }
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        if elementName == "item" || elementName == "entry" {
            let item = RSSItem(
                title: currentTitle.trimmingCharacters(in: .whitespacesAndNewlines),
                description: cleanHTML(currentDescription),
                link: currentLink.trimmingCharacters(in: .whitespacesAndNewlines),
                pubDate: currentPubDate.trimmingCharacters(in: .whitespacesAndNewlines),
                imageURL: currentImageURL.isEmpty ? extractImageFromContent() : currentImageURL,
                author: currentAuthor.isEmpty ? nil : currentAuthor.trimmingCharacters(in: .whitespacesAndNewlines),
                content: cleanHTML(currentContent)
            )

            if !item.title.isEmpty && !item.link.isEmpty {
                items.append(item)
            }

            isInsideItem = false
        }
    }
}

// MARK: - Errors
enum RSSError: LocalizedError {
    case invalidURL
    case networkError
    case parsingFailed(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid feed URL"
        case .networkError:
            return "Failed to fetch feed"
        case .parsingFailed(let reason):
            return "Failed to parse feed: \(reason)"
        }
    }
}
