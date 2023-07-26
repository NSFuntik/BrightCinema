//
//  ReviewsView.swift
//  BrightCinema
//
//  Created by NSFuntik on 11.07.2023.
//

import SwiftUI
import SwiftUIBackports
struct RatingReviewView: View {
    @StateObject var rrVM: RatingReviewViewModel
    
    @State var isReviewWriting = false
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                let averageRating = rrVM.reviews.filter { $0.rating <= 5 }.reduce(0) { $0 + Int($1.rating) } / (rrVM.reviews.isEmpty ? 1 : rrVM.reviews.count)
                StarsView(rating: averageRating).disabled(true)
                Text("(\(rrVM.reviews.count) ratings)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            if rrVM.reviewsStatus != "You have to sign in to see reviews." {
                HStack {
                    Text("Tap to Rate:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    RatingView(rating: $rrVM.selectedRating)
                        .onChange(of: rrVM.selectedRating, perform: { _ in
                            isReviewWriting = true
                        })
                }
            }
            if rrVM.reviews.isEmpty {
                Text(rrVM.reviewsStatus)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                ScrollView(.horizontal) {
                    HStack(alignment: .center, spacing: 10) {
                        ForEach($rrVM.reviews) { $review in
                            NavigationLink {
                                VStack(alignment: .center, spacing: 15) {
                                    Text("Review")
                                        .font(.system(size: 23, weight: .semibold, design: .rounded))
                                        .padding(.bottom, 10)
                                    if let createdDate = getDate(from: review.createdAt) {
                                        
                                        let createdInterval = Calendar(identifier: .iso8601).numberOfDaysBetween(createdDate, and: .now)
                                        Text("Created \(createdInterval) days ago")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    RatingView(rating: .constant(review.rating)).scaleEffect(1.2)
                                    ScrollView {
                                        VStack {
                                            Text(review.content)
                                                .font(.system(size: 18, weight: .regular, design: .rounded))
                                                .multilineTextAlignment(.leading)
                                                .padding(10)
                                            Spacer()
                                        }
                                    }
                                    .background {
                                        RoundedRectangle(cornerRadius: 13).fill(Color.secondary.opacity(0.2))
                                            .frame(width: UIScreen.main.bounds.width - 40)
                                    }
                                    Spacer()
                                }.padding(20)
                            } label: {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        StarsView(rating: review.rating)
                                        Spacer()
                                        if let createdDate = getDate(from: review.createdAt) {
                                            
                                            let createdInterval = Calendar(identifier: .iso8601).numberOfDaysBetween(createdDate, and: .now)
                                            Text("\(createdInterval) days ago")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    ScrollView {
                                        Text(review.content)
                                            .font(.system(size: 17, weight: .regular, design: .rounded))
                                            .multilineTextAlignment(.leading)
                                            .foregroundColor(.white)
                                    }
                                    
                                }
                                .padding(10)
                                .background {
                                    RoundedRectangle(cornerRadius: 13).fill(Color.secondary.opacity(0.2))
                                }
                                .frame(width: UIScreen.main.bounds.width - 40, height: 200)
                            }
                            
                            
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isReviewWriting, content: {
            VStack(alignment: .center, spacing: 15) {
                Text("Review")
                    .font(.system(size: 23, weight: .semibold, design: .rounded))
                    .padding(.bottom, 10)
                
                RatingView(rating: $rrVM.selectedRating).scaleEffect(1.2)
                VStack {
                    if #available(iOS 16.0, *) {
                        TextField("Share your opinion!", text: $rrVM.writtenReview, prompt: nil, axis: .vertical)
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .multilineTextAlignment(.leading)
                            .padding(10)
                            .backport.scrollDismissesKeyboard(.immediately)
                            .onSubmit {
                                UIApplication.shared.endEditing()
                            }
                    } else {
                        TextField("Share your opinion!", text: $rrVM.writtenReview, prompt: nil)
                            .font(.system(size: 18, weight: .regular, design: .rounded))
                            .multilineTextAlignment(.leading)
                            .padding(10)
                            .backport.scrollDismissesKeyboard(.immediately)
                            .onSubmit {
                                UIApplication.shared.endEditing()
                            }
                    }
                    Spacer()
                }
                .background {
                    RoundedRectangle(cornerRadius: 13).fill(Color.secondary.opacity(0.2))
                }
                Spacer()
                if !rrVM.writtenReview.isEmpty {
                    Button(action: {
                        Task {
                            await rrVM.submitReview()
                            isReviewWriting = false
                        }
                    }, label: {
                        Text("Submit review").foregroundColor(.white)
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                            .padding(10)
                            .padding(.horizontal, 20)
                            .background {
                                RoundedRectangle(cornerRadius: 13).fill(Color("AccentColor"))
                            }
                    })
                }
            }
            .backport.presentationDetents([.medium])
            .padding(20)
            
            
            
        })
    }
    private struct RatingView: View {
        @Binding var rating: Int
        
        var body: some View {
            HStack {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= rating ? "star.fill" : "star")
                        .foregroundColor(Color("AccentColor"))
                        .font(.system(size: 20))
                        .onTapGesture {
                            rating = star
                        }
                }
            }
        }
    }
}



