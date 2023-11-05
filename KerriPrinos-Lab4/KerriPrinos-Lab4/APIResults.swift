//
//  APIResults.swift
//  KerriPrinos-Lab4
//
//  Created by Kerri Prinos on 10/29/23.
//

import Foundation

struct APIResults: Decodable {
    let page: Int
    let total_results: Int
    let total_pages: Int
    let results: [Movie]
}
