//
//  MessageResponseTests.swift
//  AnthropicTests
//
//  Created by Reid Chatham on 12/15/23.
//

import XCTest
@testable import Anthropic
import SwiftyJSON

final class MessageResponseTests: XCTestCase {
    func testMessageResponseDecodable() throws {
        Anthropic.decode { (result: Result<Anthropic.MessageResponse, Error>) in
            switch result {
            case .success(let response):
                XCTAssert(
                    response.message?.id == "msg_013Zva2CMHLNnXjNJJKqJ2EF" &&
                    response.message?.model == "claude-3-5-sonnet-20240620" &&
                    response.message?.role == .assistant &&
                    response.message?.stop_reason == .end_turn &&
                    response.message?.stop_sequence == nil &&
                    response.type == .message &&
                    response.usage?.input_tokens == 10 &&
                    response.usage?.output_tokens == 25)
                guard case .array(let array) = response.message?.content,
                    case .text(let text) = array[0],
                    text.text == "Hi! My name is Claude."
                else { return XCTFail("Failed to decode content") }
            case .failure(let error):
                XCTFail("failed to decode data \(error.localizedDescription)")
            }
        }(try getData(filename: "message_response")!)
    }

    func testMessageResponseWithToolCallDecodable() throws {
        Anthropic.decode { (result: Result<Anthropic.MessageResponse, Error>) in
            switch result {
            case .success(_): break
            case .failure(let error):
                XCTFail("failed to decode data \(error.localizedDescription)")
            }
        }(try getData(filename: "message_response_with_tool_call")!)
    }

    func testMessageResponseEncodable() throws {
        let response = Anthropic.MessageResponse(
            content: .array([.text(.init(text: "Hi! My name is Claude."))]),
            id: "msg_013Zva2CMHLNnXjNJJKqJ2EF",
            model: "claude-3-5-sonnet-20240620",
            role: .assistant,
            stop_reason: .end_turn,
            stop_sequence: nil,
            type: .message,
            usage: .init(input_tokens: 10, output_tokens: 25))
        let data = try response.data()
        var json = JSON(data)
        json["stop_sequence"] = .null // ignore encoding nil value
        let testData = try getData(filename: "message_response")!
        let testJson = JSON(testData)
        XCTAssert(json == testJson, "failed to correctly encode the data")
    }
}
