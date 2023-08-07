//
//  StarsView.swift
//  BrightCinema
//
//  Created by NSFuntik on 11.07.2023.
//

import SwiftUI

struct RatingView: View {
    @Binding var rating: Int
    
    var body: some View {
        HStack {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .foregroundColor(Color("AccentColor"))
                    .font(.system(size: 30))
                    .onTapGesture {
                        rating = star
                    }
            }
        }
    }
}



struct StarsView: View {
    private static let MAX_RATING: Int = 5 // Defines upper limit of the rating
    @State var rating: Int
    private let fullCount: Int
    private let emptyCount: Int

    init(rating: Int) {
        self.rating = rating
        fullCount = Int(rating)
        emptyCount = Int(StarsView.MAX_RATING - rating)
    }

    var body: some View {
        HStack {
            ForEach(0..<fullCount, id: \.self) { n in
                self.fullStar.onTapGesture {
                    rating = n
                }
            }
            ForEach(0..<emptyCount, id: \.self) { _ in
                self.emptyStar
            }
        }
    }

    private var fullStar: some View {
        Image(systemName: "star.fill").scaleEffect(1.2).foregroundColor(Color("AccentColor"))
    }

    private var halfFullStar: some View {
        Image(systemName: "star.lefthalf.fill").scaleEffect(1.2).foregroundColor(Color("AccentColor"))
    }

    private var emptyStar: some View {
        Image(systemName: "star").scaleEffect(1.2).foregroundColor(Color.white)
    }
}
