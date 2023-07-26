 import Foundation

struct QuizResult: Codable {
    let quiz: Quiz
}

struct Quiz: Codable {
    let title: String
    let questions: [Question]
}

struct Question: Codable, Hashable {
    let question: String
    let options: [String]
    let answer: String
}

struct QuizScore {
    let correctCount: Int
    let incorrectCount: Int
}
