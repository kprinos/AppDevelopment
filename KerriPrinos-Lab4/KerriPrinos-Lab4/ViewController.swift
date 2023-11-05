//
//  ViewController.swift
//  KerriPrinos-Lab4
//
//  Created by Kerri Prinos on 10/24/23.
//

import UIKit


class ViewController: UIViewController, UICollectionViewDataSource,UICollectionViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var theData: [APIResults] = []
    var theImageCache: [UIImage] = []
    let apiKey = "3250d048f10c1a0ab0c9e11271c33c66"
    var foundMovies:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.title = "Movies"
        setUpCollectionView()
        searchBar.delegate = self
        activityIndicator.stopAnimating()
        activityIndicator.hidesWhenStopped = true
        // set up tab bar items with custom images
        for item in self.tabBarController?.tabBar.items ?? [] {
            item.selectedImage = item.selectedImage?.withRenderingMode(.alwaysOriginal)
            item.setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
            item.setTitleTextAttributes([.foregroundColor: UIColor.blue], for: .selected)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // want to get results for user's search when search button is clicked
        // set up empty array for theImageCache to store results relevant to search (if there is nothing matcing search then it will just display nothing)
        theImageCache = []
        collectionView.reloadData()
        let yourSearch = searchBar.text!
        // show activity indicator while searching for items
        activityIndicator.startAnimating()
        // want to search database for this term (as in Demo)
        DispatchQueue.global(qos: .userInitiated).async {
            self.fetchDataForCollectionView(yourSearch: yourSearch)
            self.cacheImages()
            DispatchQueue.main.async {
                // activity indicator stops
                self.activityIndicator.stopAnimating()
                self.collectionView.reloadData()
                if self.foundMovies == false {
                    // if no movies were found let user know
                    let alert = UIAlertController(title: "Oops!", message: "There are no movies that match your search 😢", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    func setUpCollectionView() {
        // set up collection view
        collectionView.dataSource = self
        collectionView.delegate = self
        
    }
    
    func fetchDataForCollectionView(yourSearch: String) {
        // get data to display in the collection view based on the user's search
        // need to set up our search term for urlQueryAllowed (part that immediately follows the ?)
        let yourSearchTerm = yourSearch.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        // our url: search & query for details
        let url = URL(string: "https://api.themoviedb.org/3/search/movie?query=\(yourSearchTerm!)&api_key=\(apiKey)")!
        let data = try! Data(contentsOf: url)
            // use JSON decoder
        theData = [try! JSONDecoder().decode(APIResults.self, from: data)]
        // are there results?
        if theData[0].results.count > 0 {
            foundMovies = true
            print(theData[0].results.count)
        } else {
            foundMovies = false
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
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return theImageCache.count
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("this movie")
        // pass all relevant information to our DetailedViewController
        let detailedVC = self.storyboard!.instantiateViewController(withIdentifier: "DetailedViewController") as! DetailedViewController
        let selectedMovie = theData[0].results[indexPath.section * 3 + indexPath.row]
        // send details for the selected movie to DetailedViewController
        detailedVC.selectedMovie = selectedMovie
     
        navigationController?.pushViewController(detailedVC, animated: true)
        
    }
    
    // creating context menu to add to favorites
    // implemented with help from iOS Academy video: https://www.youtube.com/watch?v=a1Agazw2JxM
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let movie = theData[0].results[indexPath.section * 3 + indexPath.row]
        let config = UIContextMenuConfiguration(
            identifier: nil, previewProvider: nil
        ) {_ in
            
            let favorite = UIAction(title: "Add to Favorites 🤩", image: nil, identifier: nil, discoverabilityTitle: nil, state: .off) {_ in
                print("tapped favorites")
                functions().addMovieToFavorites(movie)
            }
            
            let recommend = UIAction(title: "See more like this", image: nil, identifier: nil, discoverabilityTitle: nil, state: .off) {_ in
                print("tapped recommend")
                
                let recommendVC = self.storyboard!.instantiateViewController(withIdentifier: "RecommendViewController") as! RecommendViewController
                let selectedMovie = self.theData[0].results[indexPath.section * 3 + indexPath.row]
                recommendVC.selectedMovie = selectedMovie
                self.navigationController?.pushViewController(recommendVC, animated: true)
                
            }
            
            return UIMenu(title: "", image: nil, identifier: nil, options: UIMenu.Options.displayInline, children: [favorite,recommend])
        }
        return config
    }
    
    
}

