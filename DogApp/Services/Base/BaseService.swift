//
//  BaseService.swift
//  DogApp
//
//  Created by Ebin Joy on 21/07/19.
//  Copyright © 2019 Ebin Joy. All rights reserved.
//

import Foundation

typealias JsonDictionay = [String : Any]

enum ServiceResponse {
    case success(response: Data)
    case failure(message :String, statCode :Int)
    case notConnectedToInternet
}

class BaseService{
    
    var uRLSessionArray: [String :URLSession] = [:]
    
    func callEndPoint(endPoint: String, method: String, params: JsonDictionay? = [:], completion: @escaping (ServiceResponse) -> Void){
        let getURL = URL(string: AppConstant.BASE_URL + endPoint)!
        var getRequest = URLRequest(url: getURL)
        getRequest.setValue("application/json", forHTTPHeaderField: "Accept")
//        getRequest.setValue(AppConstant.API_KEY, forHTTPHeaderField: "x-api-key")
        switch method {
            case "GET":
                 getRequest.httpMethod = "GET"
              break
            default:
              break
        }
        
        let urlSesssion = URLSession.shared
        let task = urlSesssion.dataTask(with: getRequest) { (data, response, error) -> Void in
            var statusResonse = 0
            if let httpResponse = response as? HTTPURLResponse{
                statusResonse =  httpResponse.statusCode
            }
            
            if error != nil {
                self.failure(message: "Communication error", code: statusResonse, completion: completion)
                self.uRLSessionArray.removeValue(forKey: getURL.absoluteString)
                return
            }
            if data != nil {
//                do {
//                    let resultObject = try JSONSerialization.jsonObject(with: data!, options: [])
                    self.success(result: data!, headers: [:], completion: completion)
//                } catch {
//                    self.failure(message: "Unable to parse server response", code: statusResonse, completion: completion)
//                }
            } else {
                DispatchQueue.main.async(execute: {
                   self.failure(message: "Received empty response", code: statusResonse, completion: completion)
                })
            }
            self.uRLSessionArray.removeValue(forKey: getURL.absoluteString)
            return
        }
        uRLSessionArray[getURL.absoluteString] = urlSesssion
        task.resume()
    }
    
    func cancelAllRequests () {
        for dataRequest in self.uRLSessionArray {
            dataRequest.value.invalidateAndCancel()
        }
        self.uRLSessionArray.removeAll()
    }
    
    func notConnectedToInternet (completion:@escaping (ServiceResponse) -> Void) {
        completion(.notConnectedToInternet)
    }
    
    func failure (message: String, code :Int,completion:@escaping (ServiceResponse) -> Void) {
        completion(.failure(message: message, statCode: code))
    }
    
    func success (result: Data?, headers: [AnyHashable: Any], completion:@escaping (ServiceResponse) -> Void) {
        completion(.success(response: result!))
    }
    
}