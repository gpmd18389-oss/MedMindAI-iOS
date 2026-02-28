import Foundation

/// Claude API 直连客户端 - 使用 Claude Opus 4.6
class ClaudeAPIService: ObservableObject {
    static let shared = ClaudeAPIService()

    private let model = "claude-opus-4-6"
    private let anthropicVersion = "2023-06-01"

    /// API Key - 从 UserDefaults 读取（设置页面配置）
    var apiKey: String {
        get { UserDefaults.standard.string(forKey: "claude_api_key") ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: "claude_api_key") }
    }

    var baseURL: String {
        get {
            let url = UserDefaults.standard.string(forKey: "claude_base_url") ?? ""
            return url.isEmpty ? "https://api.anthropic.com/v1" : url
        }
        set { UserDefaults.standard.set(newValue, forKey: "claude_base_url") }
    }

    var isConfigured: Bool {
        !apiKey.isEmpty
    }

    // MARK: - Send Text Message

    func sendMessage(
        systemPrompt: String,
        userText: String,
        maxTokens: Int = 4096
    ) async throws -> String {
        let contentBlocks = [AnthropicContentBlock.text(userText)]
        return try await sendRaw(
            systemPrompt: systemPrompt,
            maxTokens: maxTokens,
            contentBlocks: contentBlocks
        )
    }

    // MARK: - Send Image + Text Message

    func sendMessageWithImage(
        systemPrompt: String,
        imageBase64: String,
        userText: String = "分析截图题目，给出答案和解析。",
        maxTokens: Int = 4096
    ) async throws -> String {
        let contentBlocks = [
            AnthropicContentBlock.image(base64: imageBase64),
            AnthropicContentBlock.text(userText)
        ]
        return try await sendRaw(
            systemPrompt: systemPrompt,
            maxTokens: maxTokens,
            contentBlocks: contentBlocks
        )
    }

    // MARK: - Internal

    private func sendRaw(
        systemPrompt: String,
        maxTokens: Int,
        contentBlocks: [AnthropicContentBlock]
    ) async throws -> String {
        guard !apiKey.isEmpty else {
            throw ClaudeAPIError.notConfigured
        }

        let urlString = "\(baseURL.trimmingCharacters(in: CharacterSet(charactersIn: "/")))/messages"
        guard let url = URL(string: urlString) else {
            throw ClaudeAPIError.invalidURL
        }

        let requestBody = AnthropicMessageRequest(
            model: model,
            maxTokens: maxTokens,
            system: systemPrompt.isEmpty ? nil : systemPrompt,
            messages: [
                AnthropicMessage(role: "user", content: contentBlocks)
            ]
        )

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "content-type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue(anthropicVersion, forHTTPHeaderField: "anthropic-version")
        request.timeoutInterval = 90

        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClaudeAPIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8) ?? "unknown"
            throw ClaudeAPIError.httpError(code: httpResponse.statusCode, body: body)
        }

        let decoder = JSONDecoder()
        let parsed = try decoder.decode(AnthropicMessageResponse.self, from: data)
        return parsed.content.compactMap { $0.text }.joined()
    }
}

// MARK: - Errors

enum ClaudeAPIError: LocalizedError {
    case notConfigured
    case invalidURL
    case invalidResponse
    case httpError(code: Int, body: String)

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "请先在设置中配置 API Key"
        case .invalidURL:
            return "无效的 API URL"
        case .invalidResponse:
            return "服务器返回了无效的响应"
        case .httpError(let code, let body):
            return "HTTP \(code): \(body.prefix(200))"
        }
    }
}
