//
//  CurrentWeather.swift
//  APILayerExample
//
//  Created by Roman Malinovskyi on 1/9/18.
//  Copyright © 2018 Roman Malinovskyi. All rights reserved.
//

import Foundation
import UIKit

struct CurrentWeather {
  let temperature: Double
  let appearentTemperature: Double
  let humidity: Double
  let iconURL: URL
}

extension CurrentWeather {
  var temperatureString: String {
    return "\(Int(temperature)) 'C"
  }
}

extension CurrentWeather: JSONDecodable {
  init?(JSON: [String : AnyObject]) {
    // as example
    guard let temperature = JSON["temperature"] as? Double,
    let appearentTemperature = JSON["appearentTemperature"] as? Double,
    let humidity = JSON["humidity"] as? Double,
    let iconString = JSON["icon"] as? String else {
      return nil
    }
    
    self.temperature = temperature
    self.appearentTemperature = appearentTemperature
    self.humidity = humidity
    self.iconURL = URL(string: iconString)!
  }
}
