import Foundation
import SwiftData

/// 错题本数据模型
@Model
final class WrongBookEntry {
    var title: String
    var questionText: String
    var ocrText: String
    var aiRaw: String
    var imagePath: String?
    var userNotes: String
    var analyzing: Bool
    var createdAt: Date

    init(
        title: String = "",
        questionText: String = "",
        ocrText: String = "",
        aiRaw: String = "",
        imagePath: String? = nil,
        userNotes: String = "",
        analyzing: Bool = false,
        createdAt: Date = Date()
    ) {
        self.title = title
        self.questionText = questionText
        self.ocrText = ocrText
        self.aiRaw = aiRaw
        self.imagePath = imagePath
        self.userNotes = userNotes
        self.analyzing = analyzing
        self.createdAt = createdAt
    }
}

/// AI 分析结果解析
struct AiResponseParser {
    static func parseOrNull(_ raw: String) -> AiAnalysis? {
        guard let data = raw.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(AiAnalysis.self, from: data)
    }
}
