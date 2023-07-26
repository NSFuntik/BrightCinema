import Foundation

var posterSizes = ["w92", "w154", "w185", "w342", "w500", "w780", "w1280", "original"]
var trailerQualitySettings: [String] = []
var person_id: Int?

struct Api {
    static let LOGIN_URL = "https://cinemaraids.com/"

    static let BASE_URL = "https://cinemaraids.com/api/3"
    static let KEY = "5042406e2d9a46f8e330a6b89e997af4"
    static let SCHEME = "https"
    static let HOST = "cinemaraids.com"
    static let PATH = "/api/3"
    static let REGISTER = "/auth/register"
    static let LOGIN = "/auth/login"

    
    static let youtubeThumb = "https://img.youtube.com/vi/"
    static let youtubeLink = "https://www.youtube.com/watch?v="
}

struct ParameterKeys {
    static let API_KEY = "api_key"
    static let SESSION_ID = "session_id"
    static let PAGE = "page"
    static let TOTAL_RESULTS = "total_results"
    static let REGION = "region"
    static let MOVIE_ID = "movie_id"
    static let KNOWN_FOR = "known_for"
}

struct ImageKeys {
    static let IMAGE_BASE_URL = "https://cinemaraids.com/image"
    
    struct PosterSizes {
        static let BACK_DROP = posterSizes[6]
        static let ROW_POSTER = posterSizes[2]
        static let DETAIL_POSTER = posterSizes[3]
        static let ORIGINAL_POSTER = posterSizes[6]
    }
}

struct Methods {
    static let NOW_PLAYING = "/movie/now_playing"
    static let TRENDING_WEEK = "/trending/movie/week"
    static let UPCOMING = "/movie/upcoming"
    static let TOP_RATED = "/movie/top_rated"
    static let POPULAR_ACTORS = "/person/popular"
    static let TRENDING_TV = "/trending/tv/week"
    static let REGISTER = "/register"
    static let LOGIN = "/login"
}


// Converts String to Date
extension String {
    
    func convertDateString() -> String? {
        return convert(dateString: self, fromDateFormat: "yyyy-MM-dd", toDateFormat: "MMM d, yyyy")
    }

    func convert(dateString: String, fromDateFormat: String, toDateFormat: String) -> String? {
        
        let fromDateFormatter = DateFormatter()
        fromDateFormatter.dateFormat = fromDateFormat
        
        if let fromDateObject = fromDateFormatter.date(from: dateString) {
            
            let toDateFormatter = DateFormatter()
            toDateFormatter.dateFormat = toDateFormat
            
            let newDateString = toDateFormatter.string(from: fromDateObject)
            return newDateString
        }
        return nil
    }
}
