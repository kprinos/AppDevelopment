//
//  functions.swift
//  KerriPrinos-Lab4
//
//  Created by Kerri Prinos on 10/30/23.
//

import UIKit
class functions {
    func addMovieToFavorites(_ newFavoriteMovie: Movie) {
        var currentFavorites: [Movie] = []
        // save favorite movies to property list
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        if let url = Bundle.main.url(forResource: "Movie", withExtension: "plist") {
            typealias favoriteMovies = [Movie]
            var favoriteMovie: favoriteMovies?
            do {
                let data = try Data(contentsOf: url)
                let decoder = PropertyListDecoder()
                favoriteMovie = try decoder.decode(favoriteMovies.self, from: data)
                currentFavorites = favoriteMovie!
                // check to make sure this movie isn't already in favorites before adding it to the list
                if currentFavorites.firstIndex(where: {$0.id == newFavoriteMovie.id}) == nil {
                    currentFavorites.append(newFavoriteMovie)
                    let newData = try encoder.encode(currentFavorites)
                    try newData.write(to: url)
                } 
            } catch {
                print(error)
            }
        }
    }
    
    func removeMovieFromFavorites(_ movieToRemove: Movie) {
        var currentFavorites: [Movie] = []
        // remove movie from plist
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        if let url = Bundle.main.url(forResource: "Movie", withExtension: "plist") {
            typealias favoriteMovies = [Movie]
            var favoriteMovie: favoriteMovies?
            do {
                // get the current list of favorite movies
                let data = try Data(contentsOf: url)
                let decoder = PropertyListDecoder()
                favoriteMovie = try decoder.decode(favoriteMovies.self, from: data)
                currentFavorites = favoriteMovie!
                // find and remove the selected movie
                if let index = currentFavorites.firstIndex(where: {$0.id == movieToRemove.id}) {
                    currentFavorites.remove(at: index)
                }
                // update plist
                let newData = try encoder.encode(currentFavorites)
                try newData.write(to: url)
            } catch {
                print("Error removing movie from favorites \(error)")
            }
        }
    }
}
