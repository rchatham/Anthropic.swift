import Foundation


public extension Anthropic {
    struct Tool: Codable {
        let name: String
        let description: String?
        let input_schema: InputSchema // JSON Schema object
        internal var callback: (([String:Any]) -> String?)? = nil
        public init(name: String, description: String, input_schema: InputSchema = InputSchema(properties: [:]), callback: (([String:Any]) -> String?)? = nil) {
            self.name = name
            self.description = description
            self.input_schema = input_schema
            self.callback = callback
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(String.self, forKey: .name)
            description = try container.decodeIfPresent(String.self, forKey: .description)
            input_schema = try container.decode(InputSchema.self, forKey: .input_schema)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encode(description, forKey: .description)
            try container.encode(input_schema, forKey: .input_schema)
        }

        enum CodingKeys: String, CodingKey {
            case name, description, input_schema
        }

        public struct InputSchema: Codable {
            var type: String = "object"
            var properties: [String:Property]
            var required: [String]?
            public init(properties: [String : Property] = [:], required: [String]? = nil) {
                self.properties = properties
                self.required = required
            }

            public struct Property: Codable {
                var type: String
                var enumValues: [String]?
                var description: String?
                public init(type: String, enumValues: [String]? = nil, description: String? = nil) {
                    self.type = type
                    self.enumValues = enumValues
                    self.description = description
                }
                enum CodingKeys: String, CodingKey {
                    case type, description
                    case enumValues = "enum"
                }
            }
        }
    }
}
