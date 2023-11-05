//
//  RecommendViewController.swift
//  KerriPrinos-Lab4
//
//  Created by Kerri Prinos on 10/30/23.
//

import UIKit

class RecommendViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var selectedMovie: Movie?
    var theData: [APIResults] = []
    let apiKey = "3250d048f10c1a0ab0c9e11271c33c66"
    var foundMovies: Bool = false
    var theImageCache: [UIImage] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpCollectionView()
        fetchRecommendations()
        

        // Do any additional setup after loading the view.
    }
    
    func setUpCollectionView() {
        // set up collection view
        collectionView.dataSource = self
        collectionView.delegate = self
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return theImageCache.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // set up reusable cells
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myCell", for: indexPath) as! CollectionViewCell
        let movie = theData[0].results[indexPath.section * 3 + indexPath.row]
        // want to display corresponding movie poster and title if it is available - if the image cache is empty we shouldn't show anything
        if theImageCache.count != 0 {
            cell.moviePosterView.image = theImageCache[indexPath.row]
            cell.movieTitle.text = movie.title
        } else {
            print("setting both to nil")
            cell.moviePosterView.image = nil
            cell.movieTitle.text = nil
        }
    return cell
    }
    
    func fetchRecommendations() {
            if let movieID = selectedMovie?.id, let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieID)/recommendations?api_key=\(apiKey)") {
                let task = URLSession.shared.dataTask(with: url) { data, response, error in
                    if let error = error {
                        print("Error: \(error)")
                        return
                    }
                    
                    if let data = data {
                        do {
                            let recommendations = try JSONDecoder().decode(APIResults.self, from: data)
                            if recommendations.results.count > 0 {
                                self.theData = [recommendations]
                                print(self.theData[0].results)
                                self.foundMovies = true
                                self.cacheImages() // Call to cache images
                                DispatchQueue.main.async {
                                    self.collectionView.reloadData() // Reload data after caching images
                                }
                            } else {
                                // no recommendations found
                                self.foundMovies = false
                            }
                        } catch {
                            print("Decoding error: \(error)")
                            // Handle the decoding error
                        }
                    }
                }
                task.resume()
            }
        }
    
    func cacheImages() {
        // ready image of poster to display for each relevant movie
        for movie in theData[0].results {
            // check for movie poster and get it from database - if there show default image of clapper board
            let moviePoster = movie.poster_path
            if moviePoster != nil {
                let fullImagePath = "https://image.tmdb.org/t/p/w154/" + movie.poster_path!
                let url = URL(string: fullImagePath)
                let data =  try? Data(contentsOf: url!)
                let image = UIImage(data: data!)
                theImageCache.append(image!)
            } else {
                let image = UIImage(named: "noPoster.jpg")
                theImageCache.append(image!)
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("this movie")
        // pass all relevant information to our DetailedViewController
        let detailedVC = self.storyboard!.instantiateViewController(withIdentifier: "DetailedViewController") as! DetailedViewController
        let selectedMovie = theData[0].results[indexPath.section * 3 + indexPath.row]
        // send details for the selected movie to DetailedViewController
        detailedVC.selectedMovie = selectedMovie
     
        navigationController?.pushViewController(detailedVC, animated: true)
        
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
