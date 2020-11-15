//
//  ViewController.swift
//  GitHubReposSearch
//
//  Created by Artem Musel on 15.11.2020.
//

import UIKit

/*
 In the task you noted that search should be implemented
 in 2 different threads. I make two requests with 15 repos
 in each, to fullfill this condition and show work with
 asynchronous tasks.
 
 Also git has limitation on requests. I use my account for
 authentication, but still sometimes you can reach limit.
*/

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  private let reuseIdentifier = "RepoCell"
  
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var stateLabel: UILabel!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  private var repos = [Repo]()
  
  private let networkManager = NetworkManager()
  private var debounceTimer: Timer?
  
  //MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.dataSource = self
    tableView.delegate = self
    
    searchBar.delegate = self
    
    stateLabel.text = "Enter something..."
  }
  
  //MARK: Methods
  @objc private func fetchData(searchString: String) {
    activityIndicator.startAnimating()
    stateLabel.isHidden = true
    
    networkManager.requestForRepos(searchString: searchString) { repos in
      guard let repos = repos else {
        //show placeholder
        DispatchQueue.main.async {
          self.activityIndicator.stopAnimating()
          self.stateLabel.isHidden = false
          self.stateLabel.text = searchString.isEmpty ? "Enter something..." : "Something went wrong😭\nCheck your connection"
          self.repos = []
          self.tableView.reloadData()
        }
        return
      }
      
      self.repos = repos
      //display repos
      DispatchQueue.main.async {
        if repos.isEmpty {
          self.stateLabel.isHidden = false
          self.stateLabel.text = "Nothing found🕵️‍♂️"
        }
        
        self.activityIndicator.stopAnimating()
        self.tableView.reloadData()
      }
    }
  }
  
  //MARK: TableView
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return repos.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let repoCell = self.tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? RepoTableViewCell else {
      return UITableViewCell()
    }
    
    let repo = repos[indexPath.row]
    repoCell.configure(repo)
    
    return repoCell
  }
  
  //MARK: SearchBar
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    debounceTimer?.invalidate()
    
    //wait for half a second before making request, so user won't spam while typing
    debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
      self.fetchData(searchString: searchBar.text ?? "")
    }
  }
  
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    fetchData(searchString: searchBar.text ?? "")
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
}


