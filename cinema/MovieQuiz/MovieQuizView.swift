//
//  MovieQuizView.swift
//  cinema
//
//  Created by NSFuntik on 27.06.2023.
//

import SwiftUI
import SwiftUIBackports

struct MovieQuizView: View {
    @StateObject var quizVM: QuizViewModel
    var posterPath: URL?
    
    var body: some View {
        VStack {
            Text(quizVM.quiz.title)
                .font(.system(size: 23, weight: .semibold, design: .serif))
                .padding()
            TabView {
                ForEach(quizVM.quiz.questions.indices, id: \.self) { index in
                    VStack {
                        QuestionView(question: quizVM.quiz.questions[index], selectedOption: $quizVM.selectedOptions[index])
                        if index >= quizVM.quiz.questions.endIndex - 1 {
                            
                            Button(action: quizVM.submitQuiz) {
                                Text("Submit")
                                    .font(.headline)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 13)
                                    .stroke(lineWidth: 2)
                                    .fill(Color("AccentColor")))
                                    .foregroundColor(Color("AccentColor"))
                            }.padding(.bottom, 20)
                            .padding()
                        }
                    } .backport.background ({
                        RoundedRectangle(cornerRadius: 13).fill(Color.black.opacity(0.3))
                    }).padding(.horizontal, 20)
                }
            }.tabViewStyle(
                PageTabViewStyle(indexDisplayMode: .always)
            )
           
            if let result = quizVM.quizScore {
                ResultView(result: result)
            }
        }.backport.background {
           CachedAsyncImage(
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
    
   private struct QuestionView: View {
        let question: Question
        @Binding var selectedOption: String?
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(question.question)
                    .font(.headline)
                    .padding(.bottom)
                
                ForEach(question.options, id: \.self) { option in
                    Button {
                        selectedOption = option
                    } label: {
                        HStack {
                            Text(option)
                            Spacer()
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
    
   private struct ResultView: View {
        let result: QuizScore
        
        var body: some View {
            VStack(spacing: 10) {
                Text("Quiz Result")
                    .font(.system(size: 23, weight: .semibold, design: .serif))
                    .padding()
                
                Text("Correct Answers: \(result.correctCount) 🎉")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                
                Text("Incorrect Answers: \(result.incorrectCount) ☹️")
                    .font(.system(size: 17, weight: .regular, design: .rounded))
            }
            .foregroundColor(Color("AccentColor"))
            .padding()
        }
    }
}


