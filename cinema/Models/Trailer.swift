import Foundation

struct Trailer:Codable {
    var id:String?
    var key:String?
    var name:String?
}

struct TrailersDTO:Codable {
    var id:Int?
    var results:[Trailer]?
}
