//
//  RepoTable.swift
//  GitWatch
//
//  Created by Ingo on 16.05.16.
//  Copyright © 2016 Ingo. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift

class RepositoryTableviewController: UITableViewController {
	@IBOutlet weak var activity: UIActivityIndicatorView!
	@IBOutlet weak var languageButton: UIButton!
	@IBOutlet weak var counterLabel: UILabel!

	// REALM objects
	lazy var realm: Realm! = {
		do {

			return try Realm()

		} catch let error as NSError {
		}
		return nil

	}()

	lazy var dbResults: Results<GITRealm> = {
		return self.realm.objects(GITRealm)
	}()

	override func viewDidLoad() {
		self.activity.hidden = true
		self.counterLabel.hidden = true

		self.refreshControl = UIRefreshControl()
		self.refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh\nthe list of repositories ")
		self.refreshControl!.addTarget(self, action: #selector(refreshData), forControlEvents: UIControlEvents.ValueChanged)
		self.refreshControl?.alpha = 0.0

		// print(languageResults)

		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.tableView.estimatedRowHeight = 199; // set to whatever your "average" cell height is

	}

	func refreshData () {
		self.loadData()
		self.refreshControl!.endRefreshing()
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		self.dbResults = self.realm.objects(GITRealm)

		if dbResults.count == 0 {
			loadData()
			return 0
		}

		let sortProperties = [SortDescriptor(property: "stargazers_count", ascending: false)]

		self.dbResults = self.dbResults.sorted(sortProperties)

		self.tableView.contentInset = UIEdgeInsets(top: (self.navigationController?.navigationBar.bounds.size.height)! + 22, left: 0, bottom: 0, right: 0)

		if Settings.sharedInstance.onlyWithDescription {
			self.dbResults = self.dbResults.filter("repoDescription != ''")
		}

		if Settings.sharedInstance.currentLanguage != "" {
			self.dbResults = self.dbResults.filter("repoLanguage == '\(Settings.sharedInstance.currentLanguage)'")
		}

		self.setLanguageButton()
		self.counterLabel.text = String(format: "%d Repos", dbResults.count)
		self.counterLabel.hidden = false

		self.refreshControl?.alpha = 1.0

//		if self.dbResults.count > 0 {
//			self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
//		}

		return self.dbResults.count + 1
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

		if indexPath.row < tableView.numberOfRowsInSection(0) - 1 {
			let cell = tableView.dequeueReusableCellWithIdentifier("RepositoryCell") as! RepositoryCell

			cell.updateCell(dbResults[indexPath.row], indexPath: indexPath)
//		cell?.textLabel!.text = dbResults[indexPath.row].repoName
//		cell?.detailTextLabel!.text = dbResults[indexPath.row].repoDescription
			return cell
		} else {
			let cell = tableView.dequeueReusableCellWithIdentifier("LoadMoreCell")
			return cell!
		}
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if indexPath.row < tableView.numberOfRowsInSection(0) - 1 {
			return
		}

		let count = tableView.numberOfRowsInSection(0) + 10
		loadData(count)

	}

	func loadData(count: Int = 30) {
		activity.startAnimating()
		self.activity.hidden = false
		self.counterLabel.hidden = true

		// Samples on https://help.github.com/articles/searching-repositories/

		// https://github.com/search?q=jquery+in%3Aname&type=Repositories
		// https://github.com/search?q=jquery+in%3Aname%2Cdescription&type=Repositories
		// https://github.com/search?q=jquery+in%3Areadme&type=Repositories

		// Matches repositories that are at least 30 MB.
		// https://github.com/search?q=size%3A%3E%3D30000&type=Repositories

		// Matches repositories with the word "rails" that are written in JavaScript.
		// https://github.com/search?q=rails+language%3Ajavascript&type=Repositories

//        Matches repositories with the at least 500 stars, including forked ones, that are written in PHP.
//        https://github.com/search?q=stars%3A%3E%3D500+fork%3Atrue+language%3Aphp&type=Repositories

//		let query = "q=a+swift&sort=stars&order=desc&per_page=10"
		// let networking = Networking(baseURL: "https://api.github.com/search/repositories" + "?" + query)
		let urlString = "https://api.github.com/search/repositories"

		var parameters: [String: String] = [:]

		if Settings.sharedInstance.currentLanguage == "" {
			parameters["q"] = "size:>=1"
		} else {
			parameters["q"] = "language:" + Settings.sharedInstance.currentLanguage
		}
		parameters["sort"] = "star"
		parameters["order"] = "desc"
		parameters["per_page"] = String(count)
		if Settings.sharedInstance.currentLanguage != "" {
			// parameters["language"] = "python" // Settings.sharedInstance.currentLanguage

		}

		print("vvvvvvvvvvvvvvvvvvvvvvvv")
		print(parameters)
		print("************************")
		Alamofire.request(.GET, urlString, parameters: parameters)
			.responseJSON { response in

				if let json = response.result.value {
					print(json)

					if json["items"] != nil {
						let repos = json["items"] as! NSArray

						self.realm.beginWrite()

						let documents = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0])

						let writePath = documents.URLByAppendingPathComponent("file.plist")
						// print(writePath)

						let a: NSArray = ["fhgfghhfg", "dgfdfgdfg", "dfsf"]

						a.writeToURL(writePath, atomically: true)

						var i = 0
						while i < repos.count {
							let repo = repos[i] as! [String: AnyObject]

							// print(i + 1, "-", repo["name"])
							if repo["id"] == nil {
								continue
							}

							let id = repo["id"] as! Int

							var gitRepo = GITRealm() // create a plain object

							// Check wether id is already in the database
							let predicate = NSPredicate(format: "gitID = %d", id)
							let dbResult = self.realm.objects(GITRealm).filter(predicate)
							if dbResult.count > 0 {
								gitRepo = dbResult[0]
							} else {

								gitRepo.gitID = id
							}
							gitRepo.hasWiki = repo["has_wiki"] == nil ? false : (repo["has_wiki"] as! Int == 1)

							if let stringContent = repo["description"] as? String { gitRepo.repoDescription = stringContent }
							if let stringContent = repo["language"] as? String { gitRepo.repoLanguage = stringContent }

//						gitRepo.repoDescription = repo["description"] == nil ? "" : repo["description"] as! String
//						gitRepo.repoLanguage = repo["language"] == nil ? "" : repo["language"] as! String
							gitRepo.repoName = repo["name"] == nil ? "" : repo["name"] as! String
							gitRepo.repoURL = repo["git_url"] == nil ? "" : repo["git_url"] as! String
							gitRepo.stargazers_count = repo["stargazers_count"] == nil ? 0 : repo["stargazers_count"] as! Int
							gitRepo.watchers = repo["watchers"] == nil ? 0 : repo["watchers"] as! Int

							gitRepo.updatedAt = repo["updated_at"] == nil ? "" : repo["updated_at"] as! String

							if let stringContent = repo["homepage"] as? String { gitRepo.homepage = stringContent }

							self.realm.add(gitRepo)

							i = i + 1
						}

						try! self.realm.commitWrite()
					}
					self.tableView.reloadData()
					self.activity.hidden = true
				}
		}

	}

	func valueIfExists <T> (a: [String: T], key: String, defaultValue: T) -> T {

		let value = a[key]

		print("***************", value)

		if value == nil {
			return defaultValue
		}
		return value!
	}

	func setLanguageButton() {
		if Settings.sharedInstance.currentLanguage == "" {
			self.languageButton .setTitle("(All Programming Languages)", forState: .Normal)

		} else {
			self.languageButton .setTitle(Settings.sharedInstance.currentLanguage, forState: .Normal)
		}
	}

	override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
		if identifier == "detail" {
			if tableView.indexPathForSelectedRow?.row == tableView.numberOfRowsInSection(0) - 1 {
				//
				return false
			}
		}
		return true
	}
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		print(segue.identifier)
		if segue.identifier == "detail" {
			let webViewController = segue.destinationViewController as! WebViewController
            
			let index = tableView.indexPathForSelectedRow?.row
			let repositoryURL = self.dbResults[index!].repoURL

            webViewController.gitRepo = self.dbResults[index!]
			webViewController.repositoryURL = repositoryURL

		} else if segue.identifier == "languageSettings" {
			let languageController = segue.destinationViewController as! LanguageSelection

			languageController.doneClosure = {
				self.setLanguageButton()
				self.tableView.reloadData()
				self.loadData()
			}

		}
	}
}

