//
//  Repo.swift
//  GitHubReposSearch
//
//  Created by Artem Musel on 15.11.2020.
//

import Foundation

class Repo: Decodable {
  let name: String
  let owner: RepoOwner
  let stars: Int
  //projects does not always have certain language
  let language: String?

  enum CodingKeys: String, CodingKey {
    case name, owner, language
    case stars = "stargazers_count"
  }
  
  struct RepoOwner : Decodable {
    let login: String
  }
  
  //helper for parsing
  struct RepoArray : Decodable {
    let items: [Repo]
  }
}
