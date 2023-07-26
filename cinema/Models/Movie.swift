import Foundation
enum TVGenre: Int {
    case ActionAdventure  =   10759
    case Animation        =   16
    case Comedy           =   35
    case Crime            =   80
    case Documentary      =   99
    case Drama            =   18
    case Family           =   10751
    case Kids             =   10762
    case Mystery          =   9648
    case News             =   10763
    case Reality          =   10764
    case SciFiFantasy     =   10765
    case Soap             =   10766
    case Talk             =   10767
    case WarPolitics      =   10768
    case Western          =   37
    
    var list: String {
        switch self {
        case .ActionAdventure:
            return "Action & Adventure"
        case .Animation:
            return "Animation"
        case .Comedy:
            return "Comedy"
        case .Crime:
            return "Crime"
        case .Documentary:
            return "Documentary"
        case .Drama:
            return "Drama"
        case .Family:
            return "Family"
        case .Kids:
            return "Kids"
        case .Mystery:
            return "Mystery"
        case .News:
            return "News"
        case .Reality:
            return "Reality"
        case .SciFiFantasy:
            return "Sci-Fi & Fantasy"
        case .Soap:
            return "Soap"
        case .Talk:
            return "Talk"
        case .WarPolitics:
            return "War & Politics"
        case .Western:
            return "Western"
        }
    }
}

enum Genre: Int {
    case action = 28
    case adventure = 12
    case animation = 16
    case comedy = 35
    case crime = 80
    case documentary = 99
    case drama = 18
    case family = 10751
    case fantasy = 14
    case history = 36
    case horror = 27
    case music = 10402
    case romance = 10749
    case scienceFiction = 878
    case tVMovie = 10770
    case thriller = 53
    case war = 10752
    case western = 37
    
    var list: String {
        switch self {
        case .action: return "action"
        case .adventure: return "adventure"
        case .animation: return "animation"
        case .comedy: return "comedy"
        case .crime: return "crime"
        case .documentary: return "documentary"
        case .drama: return "drama"
        case .family: return "family"
        case .fantasy: return "fantasy"
        case .history: return "history"
        case .horror: return "horror"
        case .music: return "music"
        case .romance: return "romance"
        case .scienceFiction: return "science fiction"
        case .tVMovie: return "TV Movie"
        case .thriller: return "thriller"
        case .war: return "war"
        case .western: return "western"
       
        }
    }
    
    static var allValues = [Genre]() 
}

struct Movie: Codable, Hashable, Identifiable {
    let id: Int?
    
    var profile_path: String?
    var poster_path: String?
    let title: String?
    let backdrop_path: String?
    
    let poster: String?
    let overview: String?
    let release_date: String?
    
    let video: Bool?
    var runtime: Int?
    
    let genre_ids: [Int]?
    let popularity: Double?
    var vote_average: Double?
    
    //TV
    let first_air_date: String?
    let name: String?
    var birthday: String?
}

