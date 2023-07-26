//
//  Review.swift
//  BrightCinema
//
//  Created by NSFuntik on 11.07.2023.
//

import Foundation

struct Review: Codable, Hashable, Identifiable {
    var id: UUID
    let cinemaId: Int
    let rating: Int
    let content: String
    let createdAt: String
    let updatedAt: String
    init(id: String, cinemaId: String, rating: String, content: String, createdAt: String = "", updatedAt: String = "") {
        self.id = UUID(uuidString: id) ?? UUID()
        self.cinemaId = Int(cinemaId) ?? 0
        self.rating = Int(rating) ?? 0
        self.content = content
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    enum CodingKeys: String, CodingKey {
        case id = "uuid", cinemaId, rating, content, createdAt, updatedAt
    }
}
func getDate(from dateString: String) -> Date? {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    debugPrint(formatter.date(from: dateString))
    return formatter.date(from: dateString)
}
extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from) // <1>
        let toDate = startOfDay(for: to) // <2>
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate) // <3>
        
        return numberOfDays.day!
    }
}
func getString(from date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd/MM/yy"
    return formatter.string(from: date)
}
struct ReviewDTO: Codable, Hashable{
    let cinemaId: Int
    let rating: Int
    let content: String
    
    init(cinemaId: Int, rating: Int, content: String) {
        self.cinemaId = cinemaId
        self.rating = rating
        self.content = content
    }
    enum CodingKeys: String, CodingKey {
        case cinemaId, rating, content
    }
}

