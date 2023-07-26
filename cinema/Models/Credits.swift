import Foundation

struct Cast: Codable {
    var cast_id:Int?
    var character:String?
    var credit_id:String?
    var name:String?
    var profile_path:String?
    var id:Int?
    
}
struct Crew: Codable, Identifiable {
    var credit_id:String?
    var name:String?
    var department:String?
    var job:String?
    var id:Int?
    var profile_path:String?
    
}


struct Credits: Codable
{
    var id: Int?
    var cast:[Cast]?
    var crew:[Crew]?
}
