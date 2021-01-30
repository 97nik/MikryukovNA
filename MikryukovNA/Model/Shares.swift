//
//  Shares.swift
//  MikryukovNA
//
//  Created by Никита on 30.01.2021.
//

import Foundation
struct Shares: Decodable {
  let results: [Result]
}

struct Result: Decodable {
   
    let symbol: String?
 
}
