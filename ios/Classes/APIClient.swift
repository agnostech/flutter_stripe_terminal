//
//  APIClient.swift
//  flutter_stripe_terminal
//
//  Created by Vishal Dubey on 03/12/21.
//

import StripeTerminal

class APIClient: ConnectionTokenProvider {
    
    static let shared = APIClient()
    
    func fetchConnectionToken(_ completion: @escaping ConnectionTokenCompletionBlock) {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        print(FlutterStripeTerminal.shared.serverUrl!)
        
        guard let url = URL(string: FlutterStripeTerminal.shared.serverUrl!) else {
            fatalError("Invalid backend URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer " + FlutterStripeTerminal.shared.authToken!, forHTTPHeaderField: "Authorization")
        let task = session.dataTask(with: request) { (data, response, error) in
        if let data = data {
            do {
                // Warning: casting using `as? [String: String]` looks simpler, but isn't safe:
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let secret = json?["secret"] as? String {
                    completion(secret, nil)
                }
                else {
                    let error = NSError(domain: "flutter-stripe-terminal-ios",
                                        code: 2000,
                                        userInfo: [NSLocalizedDescriptionKey: "Missing `secret` in ConnectionToken JSON response"])
                                completion(nil, error)
                    }
                }
                catch {
                        completion(nil, error)
                    }
                }
                else {
                    let error = NSError(domain: "flutter-stripe-terminal-ios",
                                        code: 1000,
                                        userInfo: [NSLocalizedDescriptionKey: "No data in response from ConnectionToken endpoint"])
                    completion(nil, error)
                    }
                }
            task.resume()
    }
}
