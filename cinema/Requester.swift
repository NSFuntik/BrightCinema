//
//  Requester.swift
//  OliScheme
//
//  Created by NSFuntik on 16.05.2023.
//

import Foundation

class Requester {
    
    public static let instance = Requester()
    
    var stringToParse: NSAttributedString?
    typealias ObjectRecieved = (_ object: NSAttributedString?) -> ()
    
    func fetchData(url: String, completion: @escaping (_ object: NSAttributedString?, _ error: Error?) -> () ) {
        guard let url = URL(string: url) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, response, error)  in
            if let error = error {
                completion(nil, error)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 404 {
                    completion(nil, error)
                    return
                }
            }
            
            if let data = data {
                guard let body = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else {
                    completion(self.stringToParse, error)
                    return
                }
                self.stringToParse = NSAttributedString(string: body as String)
            }
            
            completion(self.stringToParse, error)
            
        }.resume()
    }
}
