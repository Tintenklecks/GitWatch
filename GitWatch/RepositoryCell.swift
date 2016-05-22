//
//  RepositoryCell.swift
//  GitWatch
//
//  Created by Ingo on 16.05.16.
//  Copyright © 2016 Ingo. All rights reserved.
//

import UIKit
import RealmSwift

class RepositoryCell: UITableViewCell {

    var repo : GITRealm! = nil
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var languageLabelConstraint: NSLayoutConstraint!
	@IBOutlet weak var repoName: UILabel!
	@IBOutlet weak var repoDescription: UILabel!
	@IBOutlet weak var wikiImage: UIImageView!
	@IBOutlet weak var starLabel: UILabel!
	@IBOutlet weak var watchLabel: UILabel!
	@IBOutlet weak var languageLabel: UILabel!
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
	}

	override func setSelected(selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)

		// Configure the view for the selected state
	}

	func updateCell(gitRepo: GITRealm, indexPath: NSIndexPath) {
        self.repo = gitRepo
        favoriteButton.selected = gitRepo.favorite
        if Settings.sharedInstance.currentLanguage == "" {
            languageLabel.hidden = false
            languageLabelConstraint.constant = 13
            languageLabel.text = gitRepo.repoLanguage
        } else {
            languageLabel.hidden = true
            languageLabel.text = ""
            languageLabelConstraint.constant = 0
        }
        
		repoName.text = gitRepo.repoName
		repoDescription.text = gitRepo.repoDescription

		wikiImage.image = UIImage(named: gitRepo.hasWiki ? "iconWiki" : "iconWikiGray")
		starLabel.text = String(gitRepo.stargazers_count)
		watchLabel.text = String(gitRepo.watchers)

	}

    @IBAction func switchFavoriteState(sender: AnyObject) {
        
        if repo != nil {
            try! Realm().write({
                repo.favorite = !repo.favorite
                try! Realm().add(repo, update: true)
                
            })
            favoriteButton.selected = repo.favorite
            
            
        }
    }
}
