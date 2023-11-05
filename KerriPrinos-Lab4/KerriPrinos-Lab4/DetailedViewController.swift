//  DetailedViewController.swift
//  KerriPrinos-Lab4
//
//  Created by Kerri Prinos on 10/28/23.
//

import UIKit

class DetailedViewController: UIViewController {
    
    @IBOutlet weak var moviePoster: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var movieOverviewLabel: UILabel!
    @IBOutlet weak var citationLabel: UILabel!
    // set up required variables

    var selectedMovie: Movie?
    var currentFavorites: [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        if let movie = selectedMovie {
            self.title = movie.title
        }
        citationLabel.text = "Data Source: TMDB"
        fetchPosterImage()
        displayMovieDetails()
    }
    
    func fetchPosterImage() {
        // get high resolution poster image from the database if there is one, otherwise show the default image of a clapper board
            if let posterPath = selectedMovie?.poster_path {
                    let fullImagePath = "https://image.tmdb.org/t/p/w342/" + posterPath
                    if let url = URL(string: fullImagePath) {
                        let session = URLSession.shared
                        let task = session.dataTask(with: url) { (data, response, error) in
                            if let data = data, let image = UIImage(data: data) {
                                DispatchQueue.main.async {
                                    self.moviePoster.image = image
                                }
                            } else {
                                let image = UIImage(named: "noPoster.jpg")
                                DispatchQueue.main.async {
                                    self.moviePoster.image = image
                                }
                            }
                        }
                        task.resume()
                    } else {
                        let image = UIImage(named: "noPoster.jpg")
                        moviePoster.image = image
                    }
                } else {
                    let image = UIImage(named: "noPoster.jpg")
                    moviePoster.image = image
                }
            }
    func displayMovieDetails() {
        if let date = selectedMovie?.release_date {
            // change date format
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let formattedDate = dateFormatter.date(from: date) {
                dateFormatter.dateFormat = "MMMM dd, yyyy"
                let dateToDisplay = dateFormatter.string(from: formattedDate)
                dateLabel.text = "Release Date: \(dateToDisplay)"
            } else {
                dateLabel.text = "Release Date: -"
                print("invalid date")
            }
        } else {
            dateLabel.text = "Release Date: -"
            print("nil release date")
        }

        if let score = selectedMovie?.vote_average {
            reviewLabel.text = "Score: \((round(score * 100)) / 10.0) / 100"
        } else {
            reviewLabel.text = "Score: -"
            print("nil score")
        }

        if let summary = selectedMovie?.overview {
            movieOverviewLabel.text = "Overview: \(summary)"
        } else {
            movieOverviewLabel.text = "Overview: -"
            print("nil overview")
        }
    }

    
    @IBAction func addToFavorites(_ sender: UIButton) {
        guard let selectedMovie = selectedMovie else {return}
        // use add to favorites function
        print("button pressed")
        functions().addMovieToFavorites(selectedMovie)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
