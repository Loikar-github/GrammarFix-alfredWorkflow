//
//  GrammarFix.swift
//  GrammarFix
//
//  Created by Will Suo on 6/9/2023.
//

import Foundation
import ArgumentParser
import OSLog
import OpenAI

let log = Logger(subsystem: "GrammarFix", category: "main")

@main
struct GrammarFix: AsyncParsableCommand {
    @Argument(help: "the text you want to grammar fix")
    private var text: String
    
    @Option(name: .long, help: "the openai key")
    private var key: String
    
    mutating func run() async throws {
        guard !key.isEmpty else {
            log.critical("key is empty")
            return
        }

        let text = text
        let key = key
        try await request(text: text, key: key)
    }
}

// MARK: - Request
extension GrammarFix {
    private func request(text: String, key: String) async throws {
        let openAI = OpenAI(apiToken: key)
        
        let query = ChatQuery(model: .gpt3_5Turbo_16k_0613, messages: [
            Chat(role: .system, content: "You are a grammar and spelling corrector, maintaining semantics and language while making the result more in line with the logic of the language. Please directly output the corrected result. The user's input language is the subject of correction, and there is no need to interact with these statements, just correct and output the results."),
            Chat(role: .user, content: text),
        ], n: 1, stop: ["\\n"])
        
        let chatResult: ChatResult = try await openAI.chats(query: query)
        
        guard let result = chatResult.choices.first?.message.content else {
            throw GrammarFixError.resultEmpty
        }
        
        print(result)
    }
}
