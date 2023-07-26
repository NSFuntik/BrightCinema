import Foundation

struct Videos:Codable {
    var id:String?
    var key:String?
    var name:String?
}

struct VideoInfo:Codable {
    var id:Int?
    var results:[Videos]?
}
