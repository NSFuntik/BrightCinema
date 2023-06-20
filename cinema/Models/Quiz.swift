//
//  Quiz.swift
//  cinema
//
//  Created by NSFuntik on 27.06.2023.
//

import Foundation

// MARK: - QuizResult
struct QuizResult: Codable {
    let quiz: Quiz
}

// MARK: - Quiz
struct Quiz: Codable {
    let title: String
    let questions: [Question]
}

// MARK: - Question
struct Question: Codable {
    let question: String
    let options: [String]
    let answer: String
}
