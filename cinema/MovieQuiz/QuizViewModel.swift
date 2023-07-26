//
//  QuizViewModel.swift
//  cinema
//
//  Created by NSFuntik on 28.06.2023.
//

import Foundation
import Combine
final class QuizViewModel: ObservableObject {
    @Published var quiz: Quiz
    @Published var selectedOptions: [String?]
    @Published var quizScore: QuizScore?
    
    init(quiz: QuizResult) {
        self.quiz = quiz.quiz
        self.selectedOptions = Array(repeating: nil, count: quiz.quiz.questions.count)
    }
    
    func submitQuiz() {
        var correctCount = 0
        var incorrectCount = 0
        
        for (index, question) in quiz.questions.enumerated() {
            if selectedOptions[index] == question.answer {
                correctCount += 1
            } else {
                incorrectCount += 1
            }
        }
        
        quizScore = QuizScore(correctCount: correctCount, incorrectCount: incorrectCount)
    }
}
