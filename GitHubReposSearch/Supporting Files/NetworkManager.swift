//
//  NetworkManager.swift
//  GitHubReposSearch
//
//  Created by Artem Musel on 15.11.2020.
//

import UIKit

class NetworkManager {

  private let baseURL = "https://api.github.com"
  let pagesCount = 2
  let reposPerPage = 15 //max - 100
  
  //request for total repos
  func requestForRepos(searchString: String, completion: @escaping ([Repo]?)->Void) {
    let group = DispatchGroup()
    var reposFetched = [Int: [Repo]?]()
    
    (1...pagesCount).forEach { pageNum in
      group.enter()
      requestForRepos(onPage: pageNum, searchString: searchString, completion: { repos in
        reposFetched[pageNum] = repos
        group.leave()
      })
    }
    
    group.notify(queue: .main) {
      //error occured
      if (reposFetched.values.contains { $0 == nil }) {
        completion(nil)
        return
      }
      
      var totalRepos = [Repo]()
      reposFetched.keys.sorted().forEach {
        if let repos = reposFetched[$0]! {
          totalRepos += repos
        }
      }
      
      completion(totalRepos)
    }
  }
  
  //request for repos in one page
  private func requestForRepos(onPage page: Int, searchString: String, completion: @escaping ([Repo]?)->Void) {
    
    //Query setup
    let searchQuery = URLQueryItem(name: "q", value: searchString)
    let sortQuery = URLQueryItem(name: "sort", value: "stars")
    let orderQuery = URLQueryItem(name: "order", value: "desc")
    let amountQuery = URLQueryItem(name: "per_page", value: String(reposPerPage))
    let pageQuery = URLQueryItem(name: "page", value: String(page))
    
    var urlComponents = URLComponents()
    urlComponents.scheme = "https"
    urlComponents.host = "api.github.com"
    urlComponents.path = "/search/repositories"
    urlComponents.queryItems = [searchQuery, sortQuery, orderQuery, amountQuery, pageQuery]
    
    guard let url = urlComponents.url else {
      return
    }
    var request = URLRequest(url: url)
    
    //Authorization
    let username = "amusel"
    let password = "5f243b395ebdc4b803219f0e901b71e25c96e504"
    let loginString = "\(username):\(password)"

    guard let loginData = loginString.data(using: String.Encoding.utf8) else {
        return
    }
    let base64LoginString = loginData.base64EncodedString()
    request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")
    
    //dataTask
    let dataTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
      guard error == nil, let data = data else {
        completion(nil)
        return
      }
      
      let decoder = JSONDecoder()
      let repos = (try? decoder.decode(Repo.RepoArray.self, from: data))?.items
      
      completion(repos)
    }
    
    dataTask.resume()
  }
}
