//
//  Movie.swift
//  KerriPrinos-Lab4
//
//  Created by Kerri Prinos on 10/29/23.
//

import Foundation

struct Movie: Codable {
    let id: Int!
    let poster_path: String?
    let title: String
    let release_date: String?
    let vote_average: Double
    let overview: String?
}
