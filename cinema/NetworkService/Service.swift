//
//  Service.swift
//  Cinema Now
//
//  Created by Gina De La Rosa on 1/10/19.
//  Copyright © 2019 Gina De La Rosa. All rights reserved.
//

import Foundation
import Combine
import OpenAI

class Service: ObservableObject {
    
    // Shared session
    var session = URLSession.shared
    
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
    
    func taskForGETMethod(_ method: String, parameters: [String:AnyObject], completionHandlerForGET: @escaping (_ result: Data?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        session.invalidateAndCancel()
        
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
    //    , completionHandlerForImage: @escaping (_ imageData: Data?, _ error: NSError?) -> Void
    func taskForGETImage(_ size: String, filePath: String) async throws -> Data? {
        debugPrint(filePath)
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
    
    static func fetchMovie(with searchTerm: String) async throws -> [Movie]? {
        // URL
        let baseMovieURL = URL(string: "https://api.themoviedb.org/")
        guard let url = baseMovieURL?.appendingPathComponent("3").appendingPathComponent("search").appendingPathComponent("movie") else { throw NetworkError.invalidResponse }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let apiKeyQueryItem = URLQueryItem(name: "api_key", value: Api.KEY)
        let searchTermQueryItem = URLQueryItem(name: "query", value: searchTerm)
        components?.queryItems = [apiKeyQueryItem, searchTermQueryItem]
        
        guard let requestURL = components?.url else { throw NetworkError.invalidResponse }
        
        // REQUEST
        let request = URLRequest(url: requestURL)
        
        // DataTask + RESUME
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        
        //            guard let data = data else { completion(nil) ; return }
        
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
    static func fetchMovie(with searchTerm: String, completion: @escaping ([Movie]?) -> Void) {
        // URL
        let baseMovieURL = URL(string: "https://api.themoviedb.org/")
        guard let url = baseMovieURL?.appendingPathComponent("3").appendingPathComponent("search").appendingPathComponent("movie") else { completion(nil); return }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        let apiKeyQueryItem = URLQueryItem(name: "api_key", value: Api.KEY)
        let searchTermQueryItem = URLQueryItem(name: "query", value: searchTerm)
        components?.queryItems = [apiKeyQueryItem, searchTermQueryItem]
        
        guard let requestURL = components?.url else { completion(nil) ; return }
        
        // REQUEST
        let request = URLRequest(url: requestURL)
        
        // DataTask + RESUME
        URLSession.shared.dataTask(with: request) { (data, response, error) in
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
            URLSession.shared.dataTask(with: url) {
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
            print(url)
            // REQUEST
            let request = URLRequest(url: url)
            
            // DataTask + RESUME
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw NetworkError.invalidResponse
            }
            return data
            
            //            guard let data = data else { completion(nil) ; return }
            
        }
        else {
            throw NetworkError.urlError(URLError(.badURL))
        }
    }
    
    // Movie Details
    func movieDetail(movieID:Int) async throws -> Movie? {
        
        let getURL = "/movie/\(movieID)?api_key=\(Api.KEY)&language=en-US"
        let jsonData = try? await getDataRequest(url: getURL)
        //        { jsonData in
        do
        {
            guard let data = jsonData else { return nil }
            let results = try JSONDecoder().decode(Movie.self, from: data)
            return results
        }
        catch
        {
            throw error
        }
        //        }
    }
    
    // Movie Details
    func movieDetail(movieID:Int, completion: @escaping (Movie)->()) {
        
        let getURL = "/movie/\(movieID)?api_key=\(Api.KEY)&language=en-US"
        getDataRequest(url: getURL) { jsonData in
            do
            {
                let results = try JSONDecoder().decode(Movie.self, from: jsonData as! Data)
                completion(results)
            }
            catch
            {
                print("JSON Downloading Error!")
            }
        }
    }
    
    // Movie Videos
    func movieVideos(movieID:Int, completion: @escaping (VideoInfo)->()) {
        
        let getURL = "/movie/\(movieID)/videos?api_key=\(Api.KEY)&language=en-US"
        getDataRequest(url: getURL) { jsonData in
            do
            {
                let results = try JSONDecoder().decode(VideoInfo.self, from: jsonData as! Data)
                completion(results)
            }
            catch
            {
                print("JSON Downloading Error!")
            }
        }
    }
    
    // TV Videos
    func tvVideos(tvID:Int, completion: @escaping (VideoInfo)->()) {
        
        let getURL = "/tv/\(tvID)/videos?api_key=\(Api.KEY)&language=en-US"
        getDataRequest(url: getURL) { jsonData in
            do
            {
                let results = try JSONDecoder().decode(VideoInfo.self, from: jsonData as! Data)
                completion(results)
            }
            catch
            {
                print("JSON Downloading Error!")
            }
        }
    }
    
    
    // Movie Credits
    func movieCredits(movieID:Int, completion: @escaping (Credits)->()) {
        
        let getURL = "/movie/\(movieID)/credits?api_key=\(Api.KEY)"
        getDataRequest(url: getURL) { jsonData in
            do
            {
                let results = try JSONDecoder().decode(Credits.self, from: jsonData as! Data)
                completion(results)
            }
            catch
            {
                print("JSON Downloading Error!")
            }
        }
    }
    
    
    func personDetails(person_id:Int, completion: @escaping (Person)->()) {
        
        let getURL = "/person/\(person_id)?api_key=\(Api.KEY)&language=en-US"
        getDataRequest(url: getURL) { jsonData in
            do
            {
                
                let results = try JSONDecoder().decode(Person.self, from: jsonData as! Data)
                completion(results)
            }
            catch
            {
                print("JSON Downloading Error!")
            }
        }
    }
    
    
    func personMovieCredits(personID:Int, completion: @escaping (PeopleCredits)->()) {
        
        let getURL = "/person/\(personID)/movie_credits?api_key=\(Api.KEY)&language=en-US"
        getDataRequest(url: getURL) { jsonData in
            do
            {
                
                let results = try JSONDecoder().decode(PeopleCredits.self, from: jsonData as! Data)
                completion(results)
            }
            catch
            {
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
    
    let openAI = OpenAI(apiToken: "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")
    
    func getQuiz(forMovie movieName:String) async throws -> QuizResult? {
        //        let path = "\(Api.BASE_URL)\(url)"
        let query = ChatQuery(model: .gpt3_5Turbo0613,
                              messages: [.init(role: .user,
                                               content:
                                                                            """
Make quiz for a movie \"\(movieName)\" as JSON format like: {
"quiz": {
"title": "___TITLE___",
"questions": [
{
"question": "What is the name of the first episode in Black Mirror?",
"options": [
"___OPTION_1___",
"___OPTION_2___",
"___OPTION_3___",
"___OPTION_4___"
],
"answer": "anwser index "
},
}
without \n symbols
                                                                        
                                                                        
""")])

            let result = try? await openAI.chats(query: query)
            debugPrint(result)
            if let quizTextMessage = result?.choices.first?.message.content?.replacingOccurrences(of: "\n", with: "") {
                let jsonData = quizTextMessage.data(using: .utf8)!
                
                let quizResult = try JSONDecoder().decode(QuizResult.self, from: jsonData)
                    return quizResult
                
               
               
            } else {
                return nil
            }
        
    }
    
}
