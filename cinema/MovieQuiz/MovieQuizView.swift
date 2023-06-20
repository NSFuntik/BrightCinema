//
//  MovieQuizView.swift
//  cinema
//
//  Created by NSFuntik on 27.06.2023.
//

import SwiftUI

struct MovieQuizView: View {
    @StateObject var quizVM: QuizViewModel
     var posterPath: URL?
   
    
    var body: some View {
        
        VStack {
            Text(quizVM.quiz.title)
                .font(.system(size: 23, weight: .semibold, design: .serif))
                .padding()
            TabView {
                ForEach(quizVM.quiz.questions.indices) { index in
                    VStack {
                        QuestionView(question: quizVM.quiz.questions[index], selectedOption: $quizVM.selectedOptions[index])
                        if index >= quizVM.quiz.questions.endIndex - 1 {
                            
                            Button(action: quizVM.submitQuiz) {
                                Text("Submit")
                                    .font(.headline)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 13)
                                        .stroke(lineWidth: 3)
                                        .fill(Color("AccentColor")))
                                    .foregroundColor(Color("AccentColor"))
                            }
                            .padding()
                        }
                    }
                }
            }.tabViewStyle(
                PageTabViewStyle(indexDisplayMode: .always)
            )
            
            
            if let result = quizVM.quizScore {
                ResultView(result: result)
            }
        }.background {
            AsyncImage(
                url: posterPath!,
                content: {
                    $0
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                        .blur(radius: 5)
                        .ignoresSafeArea(.all)
                },
                placeholder: { LoaderView(tintColor: Color("AccentColor")) }
            )
            
            .scaledToFill()
            .cornerRadius(0)
            .ignoresSafeArea(.all)
        }
    }
}

struct QuestionView: View {
    let question: Question
    @Binding var selectedOption: String?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(question.question)
                .font(.headline)
                .padding(.bottom)
            
            ForEach(question.options, id: \.self) { option in
                Button(action: {
                    selectedOption = option
                }) {
                    HStack {
                        Text(option)
                        if selectedOption == option {
                            Image(systemName: "checkmark")
                        }
                    }
                    .padding()
                    .background(selectedOption == option ? Color("AccentColor").opacity(0.4) : Color.clear)
                    .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
    }
}

struct ResultView: View {
    let result: QuizScore
    
    var body: some View {
        VStack {
            Text("Quiz Result")
                .font(.system(size: 23, weight: .semibold, design: .serif))
                .padding()
            
            Text("Correct Answers: \(result.correctCount) 🎉")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
            
            Text("Incorrect Answers: \(result.incorrectCount) ☹️")
                .font(.system(size: 17, weight: .regular, design: .rounded))
        }.foregroundColor(Color("AccentColor"))
        .padding()
    }
}




