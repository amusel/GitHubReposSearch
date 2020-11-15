//
//  RepoTableViewCell.swift
//  GitHubReposSearch
//
//  Created by Artem Musel on 15.11.2020.
//

import UIKit

class RepoTableViewCell: UITableViewCell {
  
  @IBOutlet weak var repoNameLabel: UILabel!
  @IBOutlet weak var authorLoginLabel: UILabel!
  @IBOutlet weak var languageLabel: UILabel!
  @IBOutlet weak var starsCountLabel: UILabel!
  
  func configure(_ repo: Repo) {
    repoNameLabel.text = repo.name
    authorLoginLabel.text = repo.owner.login
    languageLabel.text = repo.language
    starsCountLabel.text = String(repo.stars)
  }
}
