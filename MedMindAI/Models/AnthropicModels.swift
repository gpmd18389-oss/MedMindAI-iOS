import Foundation

// MARK: - Anthropic API DTOs

struct AnthropicMessageRequest: Codable {
    let model: String
    let maxTokens: Int
    let system: String?
    let messages: [AnthropicMessage]

    enum CodingKeys: String, CodingKey {
        case model
        case maxTokens = "max_tokens"
        case system
        case messages
    }
}

struct AnthropicMessage: Codable {
    let role: String
    let content: [AnthropicContentBlock]
}

struct AnthropicContentBlock: Codable {
    let type: String
    let text: String?
    let source: ImageSource?

    static func text(_ text: String) -> AnthropicContentBlock {
        AnthropicContentBlock(type: "text", text: text, source: nil)
    }

    static func image(base64: String, mediaType: String = "image/jpeg") -> AnthropicContentBlock {
        AnthropicContentBlock(
            type: "image",
            text: nil,
            source: ImageSource(type: "base64", mediaType: mediaType, data: base64)
        )
    }
}

struct ImageSource: Codable {
    let type: String
    let mediaType: String
    let data: String

    enum CodingKeys: String, CodingKey {
        case type
        case mediaType = "media_type"
        case data
    }
}

struct AnthropicMessageResponse: Codable {
    let content: [ResponseContentBlock]
}

struct ResponseContentBlock: Codable {
    let type: String
    let text: String?
}

// MARK: - AI Analysis Model

struct AiAnalysis: Codable {
    let question: String
    let answer: String
    let oneLiner: String
    let keyPoints: String
    let steps: String
    let knowledge: String
    let mistakes: String
    let similar: String
    let userCorrect: Bool
    let optionAnalysis: [String: String]

    enum CodingKeys: String, CodingKey {
        case question, answer
        case oneLiner = "one_liner"
        case keyPoints = "key_points"
        case steps, knowledge, mistakes, similar
        case userCorrect = "user_correct"
        case optionAnalysis = "option_analysis"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        question = (try? container.decode(String.self, forKey: .question)) ?? ""
        answer = (try? container.decode(String.self, forKey: .answer)) ?? ""
        oneLiner = (try? container.decode(String.self, forKey: .oneLiner)) ?? ""
        keyPoints = (try? container.decode(String.self, forKey: .keyPoints)) ?? ""
        steps = (try? container.decode(String.self, forKey: .steps)) ?? ""
        knowledge = (try? container.decode(String.self, forKey: .knowledge)) ?? ""
        mistakes = (try? container.decode(String.self, forKey: .mistakes)) ?? ""
        similar = (try? container.decode(String.self, forKey: .similar)) ?? ""
        userCorrect = (try? container.decode(Bool.self, forKey: .userCorrect)) ?? true
        optionAnalysis = (try? container.decode([String: String].self, forKey: .optionAnalysis)) ?? [:]
    }
}
