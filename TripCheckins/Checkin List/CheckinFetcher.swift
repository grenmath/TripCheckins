//
//  CheckinFetcher.swift
//  TripCheckins
//
//  Created by Nataliya  on 8/8/17.
//  Copyright © 2017 Nataliya Patsovska. All rights reserved.
//

class FoursquareEndpointConstructor {
    static let getCheckinsEnpointString = "https://api.foursquare.com/v2/users/self/checkins"
    static let apiVersion = "20170808"
    static func checkinsURL(forUserToken authorizationToken: String,
                            from fromDate: Date?,
                            to toDate: Date?) -> URL? {
        var components = URLComponents(string: getCheckinsEnpointString)
        var queryItems = [URLQueryItem(name: "oauth_token", value: authorizationToken),
                          URLQueryItem(name: "v", value: apiVersion)]
        
        if let fromDate = fromDate {
            queryItems.append(URLQueryItem(name: "afterTimestamp", value: fromDate.timeIntervalSince1970.description))
        }
        if let toDate = toDate {
            queryItems.append(URLQueryItem(name: "beforeTimestamp", value: toDate.timeIntervalSince1970.description))
        }
        components?.queryItems = queryItems
        return components?.url
    }
}

class CheckinFetcher {
    let authorizationToken: String
    
    init(authorizationToken: String) {
        self.authorizationToken = authorizationToken
    }
    
    func fetch(with completion:@escaping ([String:Any]) -> Void) {
        fetch(from: nil, to: nil, withCompletion: completion)
    }
    
    func fetch(from fromDate: Date?, to toDate: Date?, withCompletion completion: @escaping ([String:Any]) -> Void) {
        guard let url = FoursquareEndpointConstructor.checkinsURL(forUserToken: authorizationToken, from: fromDate, to: toDate) else {
            assertionFailure("cannot create url")
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                print("error when getting checkins: \(error!.localizedDescription)")
                completion([:])
                return
            }
            do {
                guard let result = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject] else {
                    print("error trying to convert data to JSON")
                    completion([:])
                    return
                }
                DispatchQueue.main.async {
                    completion(result)
                }
            } catch  {
                print("error trying to convert data to JSON")
                completion([:])
                return
            }
        }
        task.resume()
    }
}
