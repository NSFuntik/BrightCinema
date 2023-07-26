//
//  Service.swift
//
//  Created by NSFuntik on 22.06.2023.
//

import Foundation
import Combine
import OpenAI
import KeychainAccess
import SwiftUI

final class Service: ObservableObject {
    private let keychain = Keychain(service: "dev.timmychoo.cinema")
    private let openAI = OpenAI(apiToken: "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")
    
    // Shared session
    private var session = URLSession.shared
    
    
    // MARK: - Private Helper Functions
    
    // Create URL from parameters
    private func tmdbURLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = Api.SCHEME
        components.host = Api.HOST
        components.path = Api.PATH + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    
    // MARK: - Handle Get Requests
    
    func taskForGETMethod(_ method: String,
                          parameters: [String:AnyObject],
                          completionHandlerForGET: @escaping (_ result: Data?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        //        session.invalidateAndCancel()
        // Setup request
        var parametersWithApiKey = parameters
        parametersWithApiKey[ParameterKeys.API_KEY] = Api.KEY as AnyObject?
        
        
        let request = NSMutableURLRequest(url: tmdbURLFromParameters(parametersWithApiKey, withPathExtension: method))
        
        // Make Request
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            func sendRetryError(_ error: String, retryAfter retry: Int) {
                print(error)
                let userInfo: [String : Any] = [NSLocalizedDescriptionKey : error, "Retry-After" : retry]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 429, userInfo: userInfo))
            }
            
            // Handle error
            guard (error == nil) else {
                sendError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            // Response after call
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 429,
                   let retryString = httpResponse.allHeaderFields["Retry-After"] as? String,
                   let retry = Int(retryString) {
                    sendRetryError("Your request returned a status code of: \(String(describing: (response as? HTTPURLResponse)?.statusCode))", retryAfter: retry)
                } else {
                    sendError("Your request returned a status code of: \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
                }
                return
            }
            
            // Get data
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            // Return data
            completionHandlerForGET(data, nil)
        }
        // Start the request
        task.resume()
        return task
    }
    
    // MARK: - Handle Get Image Requests
    func taskForGETImage(_ size: String, filePath: String) async throws -> Data? {
        
        let baseURL = URL(string: ImageKeys.IMAGE_BASE_URL)!
        let url = baseURL.appendingPathComponent(size).appendingPathComponent(filePath)
        let request = URLRequest(url: url)
        
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        return data
    }
    
    func fetchMovie(with searchTerm: String) async throws -> [Movie]? {
        // URL
        let baseMovieURL = URL(string: "https://cinemaraids.com/api/")
        guard let url = baseMovieURL?.appendingPathComponent("3").appendingPathComponent("search").appendingPathComponent("movie") else { throw NetworkError.invalidResponse }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let apiKeyQueryItem = URLQueryItem(name: "api_key", value: Api.KEY)
        let searchTermQueryItem = URLQueryItem(name: "query", value: searchTerm)
        components?.queryItems = [apiKeyQueryItem, searchTermQueryItem]
        
        guard let requestURL = components?.url else { throw NetworkError.invalidResponse }
        
        // REQUEST
        let request = URLRequest(url: requestURL)
        
        // DataTask + RESUME
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        do {
            let movieResults = try JSONDecoder().decode(MovieResults.self, from: data)
            let movies = movieResults.results
            return movies
        } catch {
            print("There was an error with searching: \(error.localizedDescription)")
            throw error
        }
        
    }
    
    // MARK: - Search Movies
    func fetchMovie(with searchTerm: String, completion: @escaping ([Movie]?) -> Void) {
        // URL
        let baseMovieURL = URL(string: "https://cinemaraids.com/api/")
        guard let url = baseMovieURL?.appendingPathComponent("3").appendingPathComponent("search").appendingPathComponent("movie") else { completion(nil); return }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let apiKeyQueryItem = URLQueryItem(name: "api_key", value: Api.KEY)
        let searchTermQueryItem = URLQueryItem(name: "query", value: searchTerm)
        components?.queryItems = [apiKeyQueryItem, searchTermQueryItem]
        
        guard let requestURL = components?.url else { completion(nil) ; return }
        
        // REQUEST
        let request = URLRequest(url: requestURL)
        
        // DataTask + RESUME
        session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("There was an error \(error.localizedDescription)")
                completion (nil)
                return
            }
            
            guard let data = data else { completion(nil) ; return }
            
            do {
                let movieResults = try JSONDecoder().decode(MovieResults.self, from: data)
                let movies = movieResults.results
                completion(movies)
            } catch {
                print("There was an error with searching: \(error.localizedDescription)")
                
                completion(nil)
                return
            }
        }.resume()
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////
    // MARK: Notes - May want to refactor this later into the same style above.
    
    // MARK: Simplistic version of requesting data
    func getDataRequest(url:String, onCompletion:@escaping (Any)->()){
        let path = "\(Api.BASE_URL)\(url)"
        if let url = URL(string: path) {
            print(url)
            session.dataTask(with: url) {
                (data, response,error) in
                
                guard let data = data, error == nil, response != nil else{
                    print("Something is wrong: \(String(describing: error?.localizedDescription))")
                    return
                }
                onCompletion(data)
            }.resume()
        }
        else {
            print("Unable to create URL")
        }
    }
    
    func getDataRequest(url:String) async throws -> Data? {
        let path = "\(Api.BASE_URL)\(url)"
        if let url = URL(string: path) {
            // REQUEST
            let request = URLRequest(url: url)
            
            // DataTask + RESUME
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw NetworkError.invalidResponse
            }
            return data
        }
        else {
            throw NetworkError.urlError(URLError(.badURL))
        }
    }
    
    // Movie Details
    func movieDetail(movieID:Int) async throws -> Movie? {
        
        let getURL = "/movie/\(movieID)?api_key=\(Api.KEY)&language=en-US"
        let jsonData = try? await getDataRequest(url: getURL)
        do {
            guard let data = jsonData else { return nil }
            let results = try JSONDecoder().decode(Movie.self, from: data)
            return results
        }
        catch {
            throw error
        }
    }
    
    // Movie Details
    func movieDetail(movieID:Int, completion: @escaping (Movie)->()) {
        
        let getURL = "/movie/\(movieID)?api_key=\(Api.KEY)&language=en-US"
        getDataRequest(url: getURL) { jsonData in
            do {
                let results = try JSONDecoder().decode(Movie.self, from: jsonData as! Data)
                completion(results)
            }
            catch {
                print("JSON Downloading Error!")
            }
        }
    }
    
    // Movie Videos
    func movieVideos(movieID:Int, completion: @escaping (VideoInfo)->()) {
        
        let getURL = "/movie/\(movieID)/videos?api_key=\(Api.KEY)&language=en-US"
        getDataRequest(url: getURL) { jsonData in
            do {
                let results = try JSONDecoder().decode(VideoInfo.self, from: jsonData as! Data)
                completion(results)
            }
            catch {
                print("JSON Downloading Error!")
            }
        }
    }
    
    // TV Videos
    func tvVideos(tvID:Int, completion: @escaping (VideoInfo)->()) {
        
        let getURL = "/tv/\(tvID)/videos?api_key=\(Api.KEY)&language=en-US"
        getDataRequest(url: getURL) { jsonData in
            do {
                let results = try JSONDecoder().decode(VideoInfo.self, from: jsonData as! Data)
                completion(results)
            }
            catch {
                print("JSON Downloading Error!")
            }
        }
    }
    
    
    // Movie Credits
    func movieCredits(movieID:Int, completion: @escaping (Credits)->()) {
        
        let getURL = "/movie/\(movieID)/credits?api_key=\(Api.KEY)"
        getDataRequest(url: getURL) { jsonData in
            do {
                let results = try JSONDecoder().decode(Credits.self, from: jsonData as! Data)
                completion(results)
            }
            catch {
                print("JSON Downloading Error!")
            }
        }
    }
    
    
    func personDetails(person_id:Int, completion: @escaping (Person)->()) {
        
        let getURL = "/person/\(person_id)?api_key=\(Api.KEY)&language=en-US"
        getDataRequest(url: getURL) { jsonData in
            do {
                let results = try JSONDecoder().decode(Person.self, from: jsonData as! Data)
                completion(results)
            }
            catch {
                print("JSON Downloading Error!")
            }
        }
    }
    
    
    func personMovieCredits(personID:Int, completion: @escaping (PeopleCredits)->()) {
        
        let getURL = "/person/\(personID)/movie_credits?api_key=\(Api.KEY)&language=en-US"
        getDataRequest(url: getURL) { jsonData in
            do {
                let results = try JSONDecoder().decode(PeopleCredits.self, from: jsonData as! Data)
                completion(results)
            }
            catch {
                print("JSON Downloading Error!")
            }
        }
    }
    
    func smallImageURL(path:String)->URL?{
        if let url = URL(string: ImageKeys.PosterSizes.DETAIL_POSTER+path){
            return url
        }
        return nil
    }
    
    func bigImageURL(path:String)->URL?{
        if let url = URL(string: ImageKeys.PosterSizes.DETAIL_POSTER+path){
            return url
        }
        return nil
    }
    
    
    func youtubeThumb(path:String)->URL?{
        if let url = URL(string: Api.youtubeThumb+path+"/0.jpg"){
            return url
        }
        return nil
    }
    
    
    func youtubeURL(path:String)->URL?{
        if let url = URL(string: Api.youtubeLink+path){
            return url
        }
        return nil
    }
    
    
    func getQuiz(forMovieNamed movieName:String) async throws -> QuizResult? {
        //        let path = "\(Api.BASE_URL)\(url)"
        let query = ChatQuery(model: .gpt3_5Turbo0613,
                              messages: [.init(role: .user,
                                               content:
                                                                            """
Make quiz for a movie \"\(movieName)\" in 10 questions as JSON format like: {
"quiz": {
"title": "___TITLE___",
"questions": [
{
"question": "___QUESTION___",
"options": [
"___OPTION_1___",
"___OPTION_2___",
"___OPTION_3___",
"___OPTION_4___"
],
"answer": "___ANSWER___"
},
}
""")])
        
        let result = try? await openAI.chats(query: query)
        //            debugPrint(result)
        if let quizTextMessage = result?.choices.first?.message.content?.replacingOccurrences(of: "\n", with: "") {
            let jsonData = quizTextMessage.data(using: .utf8)!
            let quizResult = try JSONDecoder().decode(QuizResult.self, from: jsonData)
            return quizResult
        } else {
            return nil
        }
        
    }
    func getOverview(forMovieNamed movieName:String) async throws -> String? {
        let query = ChatQuery(model: .gpt3_5Turbo0613,
                              messages: [.init(role: .user,
                                               content: "Make overview for a movie \"\(movieName)\"")])
        let result = try? await openAI.chats(query: query)
        if let quizTextMessage = result?.choices.first?.message.content {
            return quizTextMessage
        } else {
            return nil
        }
        
    }
    
    func auth(accessType: AccessType, username: String, fingerprint: UUID, password: String) async throws -> String? {
        debugPrint(username, fingerprint, password)
        let path = "\(Api.LOGIN_URL)auth/login"
        let accessParams = AccessParameters(username: password,
                                            fingerprint: fingerprint.uuidString,
                                            password: password)
        do {
            let uploadData = try JSONEncoder().encode(accessParams)
            debugPrint(try JSONDecoder().decode(AccessParameters.self, from: uploadData))
            guard let url = URL(string: path) else {
                throw NetworkError.urlError(URLError(.badURL))
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let (data, response) = try await URLSession.shared.upload(for: request, from: uploadData)
            debugPrint(response)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                    throw NetworkError.invalidCredentials
                }
                throw NetworkError.invalidResponse
            }
            let result = try JSONDecoder().decode(AccessData.self, from: data)
            debugPrint("UUID: ", fingerprint)

            debugPrint("ACCESSTOKEN: ", result.accessToken)
            return result.accessToken
        }
        catch {
            throw error
        }
        
    }
    
    func isUsernameUnique(username: String) async throws -> Bool {
        let path = "\(Api.LOGIN_URL)users/exist/\(username)"
        
        if let url = URL(string: path) {
            print(url)
            // REQUEST
            let request = URLRequest(url: url)
            
            // DataTask + RESUME
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw NetworkError.invalidResponse
            }
            
            let isExist = String(decoding: data, as: UTF8.self)
            
            return isExist == "true" ? false : true
        }
        else {
            throw NetworkError.urlError(URLError(.badURL))
        }
        
    }
    
    static func deleteUser() async throws {
        let path = "\(Api.LOGIN_URL)users/me"
        let keychain = Keychain(service: "dev.timmychoo.cinema")
        
        if let url = URL(string: path), let accessKey = keychain["accessKey"] {

            // REQUEST
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.addValue("Bearer \(accessKey)", forHTTPHeaderField: "Authorization")
            
            let (_, response) = try await URLSession.shared.data(for: request)
            debugPrint(response)
            keychain["accessKey"] = nil
            keychain["userID"] = nil
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw NetworkError.invalidResponse
            }
            
        }
        else {
            throw NetworkError.urlError(URLError(.badURL))
        }
        
    }
    
    func fetchReviews(for cinemaId: Int) async throws -> [Review]? {
        // URL
        let path = "https://cinemaraids.com/reviews/cinema/\(cinemaId)"
        guard let url = URL(string: path) else { throw NetworkError.invalidResponse }
        
        // REQUEST
        var request = URLRequest(url: url)
        let accessToken = keychain["accessKey"] ?? "767532218439792%7C7db602baa28c869c6b11bb8c5065f773"
        
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        // DataTask + RESUME
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        do {
            let results = try JSONDecoder().decode([Review].self, from: data)
            debugPrint(results)
            return results
        } catch {
            print("There was an error with searching: \(error.localizedDescription)")
            throw error
        }
    }
    
    func submitReview(cinemaId: Int, rating: Int, content: String) async throws {
        let path = "\(Api.LOGIN_URL)reviews/write"
        let reviewDto = ReviewDTO(cinemaId: cinemaId, rating: rating, content: content)
        do {
            let uploadData = try JSONEncoder().encode(reviewDto)
            debugPrint(try JSONDecoder().decode(ReviewDTO.self, from: uploadData))
            guard let url = URL(string: path) else {
                throw NetworkError.urlError(URLError(.badURL))
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let accessToken: String = keychain["accessKey"] ?? "767532218439792%7C7db602baa28c869c6b11bb8c5065f773"
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            let (_, response) = try await URLSession.shared.upload(for: request, from: uploadData)
            debugPrint(response)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                    throw NetworkError.invalidCredentials
                }
                throw NetworkError.invalidResponse
            }
//            let result = try JSONDecoder().decode(AccessData.self, from: data)
        }
        catch {
            throw error
        }
    }
    
    func submitVideo(url: String, title: String) async throws {
        let path = "\(Api.LOGIN_URL)files/upload"
//        do {
            guard let requestURL = URL(string: path), let url = URL(string: url) else {
                throw NetworkError.urlError(URLError(.badURL))
            }
            let videoURLModel = Video(url: url.absoluteString, title: title)
            let uploadData = try JSONEncoder().encode(videoURLModel)
            debugPrint(try JSONDecoder().decode(Video.self, from: uploadData))
         
            
            var request = URLRequest(url: requestURL)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            guard let accessToken: String = keychain["accessKey"] else {
                throw NetworkError.invalidCredentials
            }
            request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            let (_, response) = try await URLSession.shared.upload(for: request, from: uploadData)
            debugPrint(response)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 401 {
                    throw NetworkError.invalidCredentials
                }
                throw NetworkError.invalidResponse
            }
//            let result = try JSONDecoder().decode(AccessData.self, from: data)
//        }
//        catch {
//            throw error
//        }
    }
    
    func fetchUserVideos() async throws -> [File] {
        let path = "\(Api.LOGIN_URL)users/me/files"
        guard let url = URL(string: path) else { throw NetworkError.urlError(URLError(.badURL)) }
        
        // REQUEST
        var request = URLRequest(url: url)
        guard let accessToken: String = keychain["accessKey"] else {
            throw NetworkError.invalidCredentials
        }
              
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        // DataTask + RESUME
        let (data, response) = try await session.data(for: request)
        debugPrint(response)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        do {
            let results = try JSONDecoder().decode(FilesResponse.self, from: data)
            debugPrint(results)
            return results.files
        } catch {
            print("There was an error with searching: \(error.localizedDescription)")
            throw error
        }
    }
    
    func fetchVideo(uuid: String) async throws -> Data {
        let path = "\(Api.LOGIN_URL)files/\(uuid)"
        guard let url = URL(string: path) else { throw NetworkError.urlError(URLError(.badURL)) }
        
        // REQUEST
        var request = URLRequest(url: url)
        guard let accessToken: String = keychain["accessKey"] else {
            throw NetworkError.invalidCredentials
        }
              
        request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        // DataTask + RESUME
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        return data
        
    }
    
    func deleteFile(uuid: String) async throws {
        let path = "\(Api.LOGIN_URL)files/\(uuid)"
        let keychain = Keychain(service: "dev.timmychoo.cinema")
        
        if let url = URL(string: path), let accessKey = keychain["accessKey"] {

            // REQUEST
            var request = URLRequest(url: url)
            request.httpMethod = "DELETE"
            request.addValue("Bearer \(accessKey)", forHTTPHeaderField: "Authorization")
            
            let (_, response) = try await URLSession.shared.data(for: request)
            debugPrint(response)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw NetworkError.invalidResponse
            }
            
        }
        else {
            throw NetworkError.urlError(URLError(.badURL))
        }
        
    }
    
    
}
