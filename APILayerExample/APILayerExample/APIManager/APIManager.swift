//
//  APIManager.swift
//  APILayerExample
//
//  Created by Roman Malinovskyi on 1/9/18.
//  Copyright © 2018 Roman Malinovskyi. All rights reserved.
//

import Foundation

typealias JSONTask = URLSessionDataTask
typealias JSONCompletionHandler = ([String: AnyObject]?, HTTPURLResponse?, Error?) -> Void

enum APIResult<T> {
  case Success(T)
  case Failure(Error)
}

struct Errors {
  static let APINetworkingErrorDomain = "com.somedomain.error.constant"
  static let APIMissingHTTPResponseError = 100
  static let APIParseError = 150
}

protocol JSONDecodable {
  init?(JSON: [String: AnyObject])
}

protocol FinalURLPoint {
  var baseURL: URL { get }
  var path: String { get }
  var request: URLRequest { get }
}

protocol APIManager {
  var sessionConfiguration: URLSessionConfiguration { get }
  var session: URLSession { get }
  
  func JSONTaskWith(request: URLRequest, completionHandler:@escaping JSONCompletionHandler) -> JSONTask
  func fetch<T>(request: URLRequest, parse: @escaping ([String: AnyObject?]) -> T?, completionHandler:@escaping (APIResult<T>) -> Void)
}

extension APIManager {
  func JSONTaskWith(request: URLRequest, completionHandler:@escaping JSONCompletionHandler) -> JSONTask  {
    
    let dataTask = session.dataTask(with: request) { (data, response, error) in
      
      guard let HTTPResponse = response as? HTTPURLResponse else {
        
        let userInfo = [
          NSLocalizedDescriptionKey: NSLocalizedString("Missing HTTP Response", comment: "")
        ]
        let error = NSError(domain: Errors.APINetworkingErrorDomain, code: Errors.APIMissingHTTPResponseError, userInfo: userInfo)
        
        completionHandler(nil, nil, error)
        return
      }
      
      if data == nil {
        if let error = error {
          completionHandler(nil, HTTPResponse, error)
        }
      } else {
        switch HTTPResponse.statusCode {
        case 200:
          do {
            let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: AnyObject]
            completionHandler(json, HTTPResponse, nil)
          } catch let error as NSError {
            completionHandler(nil, HTTPResponse, error)
          }
          
        default:
          print("We have got response status \(HTTPResponse.statusCode)")
        }
      }
    }
    
    return dataTask
  }
  
  func fetch<T>(request: URLRequest, parse: @escaping ([String: AnyObject?]) -> T?, completionHandler:@escaping (APIResult<T>) -> Void) {
    
    let dataTask = JSONTaskWith(request: request) { (json, response, error) in
      
      guard let json = json else {
        if let error = error {
          completionHandler(.Failure(error))
        }
        return
      }
      
      if let value = parse(json) {
        completionHandler(.Success(value))
      } else {
        let error = NSError(domain: Errors.APINetworkingErrorDomain, code: Errors.APIParseError, userInfo: nil)
        completionHandler(.Failure(error))
      }
    }
    
    dataTask.resume()
  }
}
