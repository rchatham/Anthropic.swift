import Foundation

public extension Anthropic {
    struct Message: Codable {
        public let role: Role
        public let content: Content

        enum CodingKeys: String, CodingKey {
            case role, content
        }

        public init(role: Role, content: String) {
            self.role = role
            self.content = .string(content)
        }

        public init(role: Role, content: Content) {
            self.role = role
            self.content = content
        }
    }

    enum Role: String, Codable {
        case user, assistant
    }

    enum Content: Codable {
        case string(String)
        case array([ContentType])

        public var description: String {
            switch self {
            case .string(let str): return "text: \(str)"
            case .array(let arry): return "content: \(arry)"
            }
        }

        public var string: String? {
            if case .string(let str) = self { return str } else { return nil }
        }

        public enum ContentType: Codable, CustomStringConvertible {
            case text(TextContent)
            case image(ImageContent)
            case toolUse(ToolUse)
            case toolResult(ToolResult)

            public var description: String {
                switch self {
                case .text(let txt): return "text: \(txt.text)"
                case .image(let img): return "image: \(img.source.media_type)"
                case .toolUse(let toolUse): return "tool use: \(toolUse.name)"
                case .toolResult(let toolResult): return "tool result: \(toolResult.content.description)"
                }
            }

            public var type: String {
                switch self {
                case .image(let img): return img.type
                case .text(let txt): return txt.type
                case .toolUse(let tool): return tool.type
                case .toolResult(let result): return result.type
                }
            }

            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if let text = try? container.decode(TextContent.self) { self = .text(text) }
                else if let img = try? container.decode(ImageContent.self) { self = .image(img) }
                else if let toolUse = try? container.decode(ToolUse.self) { self = .toolUse(toolUse) }
                else if let toolResult = try? container.decode(ToolResult.self) { self = .toolResult(toolResult) }
                else { throw DecodingError.typeMismatch(ContentType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unknown content type")) }
            }

            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                case .text(let txt): try container.encode(txt)
                case .image(let img): try container.encode(img)
                case .toolUse(let toolUse): try container.encode(toolUse)
                case .toolResult(let toolResult): try container.encode(toolResult)
                }
            }

            public struct TextContent: Codable {
                var type: String = "text"
                public let text: String
                public init(text: String) {
                    self.text = text
                }
            }

            public struct ImageContent: Codable {
                var type: String = "image"
                public let source: ImageSource
                public init(source: ImageSource) {
                    self.source = source
                }

                public struct ImageSource: Codable {
                    var type: String = "base64"
                    public let media_type: MediaType
                    public let data: String
                    public init(data: String, media_type: MediaType) {
                        self.media_type = media_type
                        self.data = data
                    }

                    public enum MediaType: String, Codable {
                        case jpeg = "image/jpeg", png = "image/png", gif = "image/gif", webp = "image/webp"
                    }
                }
            }

            public struct ToolUse: Codable {
                var type: String = "tool_use"
                public let id: String
                public let name: String
                public let input: String
            }

            public struct ToolResult: Codable {
                var type: String = "tool_result"
                public let tool_use_id: String
                public let is_error: Bool
                public let content: Content // Cannot be toolUse or toolResult ContentType
            }
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let str = try? container.decode(String.self) { self = .string(str) }
            else if let arr = try? container.decode([ContentType].self) { self = .array(arr) }
            else { throw DecodingError.typeMismatch(Content.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unknown content type")) }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .string(let txt): try container.encode(txt)
            case .array(let array): try container.encode(array)
            }
        }
    }
}
