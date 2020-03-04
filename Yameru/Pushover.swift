//
//  Pushover.swift
//  Yameru
//
//  Created by Victor Ingman on 2020-03-04.
//  Copyright © 2020 Sun Labs. All rights reserved.
//

import Foundation

class Pushover {
    var appToken: String!
    var userToken: String!
    let pushoverEndpoint = URL(string: "https://api.pushover.net/1/messages")!
    init(app: String, user: String) {
        self.appToken = app
        self.userToken = user
    }
    func request() -> URLRequest {
        var request = URLRequest(url: self.pushoverEndpoint)
        request.httpMethod = "POST"
        return request
    }
    
    func send(message: String, priority: String = "1") {
        if (self.appToken.isEmpty || self.userToken.isEmpty) {
            return
        }
        let session = URLSession.shared
        var request = self.request()
        var components = URLComponents(url: self.pushoverEndpoint, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "token", value: self.appToken),
            URLQueryItem(name: "user", value: self.userToken),
            URLQueryItem(name: "message", value: message),
            URLQueryItem(name: "priority", value: priority),
        ]
        if (priority == "2") {
            components.queryItems?.append(URLQueryItem(name: "expire", value: "3600"))
            components.queryItems?.append(URLQueryItem(name: "retry", value: "60"))
        }
        let query = components.url!.query
        request.httpBody = Data(query!.utf8)
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

            guard error == nil else {
                return
            }

            guard let data = data else {
                return
            }

            do {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print(json)
                    // handle json...
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
    
    func test () {
        self.send(message: "Yameru says hello!", priority: "0")
    }
}
