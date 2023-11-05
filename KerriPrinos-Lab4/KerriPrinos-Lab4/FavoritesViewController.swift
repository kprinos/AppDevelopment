//
//  FavoritesViewController.swift
//  KerriPrinos-Lab4
//
//  Created by Kerri Prinos on 10/29/23.
//

import UIKit

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    @IBOutlet weak var tableView: UITableView!
    var theData: [Movie] = []
    var currentFavorites: [Movie] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Favorites"
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTableView()
        fetchDataForTableView()
        tableView.reloadData()
    }
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func fetchDataForTableView() {
        // get favorites from property list display in the table
        
        if let url = Bundle.main.url(forResource: "Movie", withExtension: "plist") {
            typealias favoriteMovies = [Movie]
            var favoriteMovie: favoriteMovies?
            do {
                let data = try Data(contentsOf: url)
                let decoder = PropertyListDecoder()
                favoriteMovie = try decoder.decode(favoriteMovies.self, from: data)
                theData = favoriteMovie!
            } catch {
                print(error)
            }
        }
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(theData.count)
        return theData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        cell.textLabel!.text = theData[indexPath.row].title
        return cell
    }
    
    
    // Methods to delete favorites from the list
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // make row editable
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // function to delete row from datasource and table
        if editingStyle == .delete {
            let movieToRemove = theData[indexPath.row]
            theData.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            functions().removeMovieFromFavorites(movieToRemove)
        }
        tableView.reloadData()
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
