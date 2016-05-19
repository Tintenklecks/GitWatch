//
//  LanguageSelection.swift
//  GitWatch
//
//  Created by Ingo on 17.05.16.
//  Copyright © 2016 Ingo. All rights reserved.
//

import UIKit
import RealmSwift

class LanguageSelection: UITableViewController {
	lazy var realm: Realm! = {
		do {

			return try Realm()

		} catch let error as NSError {
		}
		return nil

	}()

	// TODO: Replace inline code with plist
	// var languages: Results <LanguagesRealm>?

	lazy var languages: Results<LanguagesRealm> = {
		let result = self.realm.objects(LanguagesRealm)
		if result.count == 0 {
			self.realm.beginWrite()
			let languages = [

				"ApacheConf": false,
				"AppleScript": false,
				"Assembly": false,
				"Bison": false,
				"C": true,
				"C#": true,
				"C++": true,
				"Ceylon": false,
				"Clojure": false,
				"CMake": false,
				"Cobol": false,
				"CoffeeScript": false,
				"Common Lisp": false,
				"Component Pascal": false,
				"CSS": false,
				"Cuda": false,
				"D": false,
				"Dart": false,
				"Delphi": false,
				"Docker": false,
				"Elixir": false,
				"Elm": false,
				"Emacs Lisp": false,
				"Erlang": false,
				"F#": false,
				"Fortran": false,
				"GLSL": false,
				"Go": false,
				"Gosu": false,
				"Groff": false,
				"Groovy": false,
				"Hack": false,
				"Haskell": false,
				"HTML": true,
				"Java": true,
				"JavaScript": true,
				"JSON": false,
				"Jupyter Notebook": false,
				"Lasso": false,
				"Logos": false,
				"Lua": false,
				"Makefile": false,
				"Markdown": false,
				"Matlab": false,
				"Modelica": false,
				"Nginx": false,
				"Objective-C": true,
				"Objective-C++": false,
				"OCaml": false,
				"OpenSCAD": false,
				"Pascal": false,
				"Perl": true,
				"PHP": true,
				"PLpgSQL": false,
				"PowerShell": false,
				"Processing": false,
				"Protocol Buffer": false,
				"Puppet": false,
				"PureBasic": false,
				"Python": true,
				"R": false,
				"Ruby": true,
				"Rust": false,
				"SaltStack": false,
				"Scala": false,
				"Shell": false,
				"Swift": true,
				"TeX": false,
				"TypeScript": false,
				"VimL": false,
				"Visual Basic": true,
				"XML": false,
				"XSLT": false,

			]

			for (key, value) in languages {

				let language = LanguagesRealm()
				language.language = key
				language.topLanguage = value
				self.realm.add(language)
			}
			try! self.realm.commitWrite()

		}
		return result
	}()

	var doneClosure: () -> (Void) = { }

	@IBOutlet weak var starredSegmentedControl: UISegmentedControl!
	override func viewDidLoad() {

		super.viewDidLoad()
		let _ = languages

		if Settings.sharedInstance.onlyFavoriteLanguages {
			starredSegmentedControl.selectedSegmentIndex = 0
		} else {
			starredSegmentedControl.selectedSegmentIndex = 1
		}

	}

	// MARK: - TableView -

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		languages = realm.objects(LanguagesRealm).sorted("language") // .filter(predicate)
		if Settings.sharedInstance.onlyFavoriteLanguages {
			languages = languages.filter("topLanguage == true")
		}

		return languages.count + 1
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("LanguageCell")
		if indexPath.row == 0 {
			cell?.textLabel?.text = "(All Programming Languages)"
		} else {
			cell?.textLabel?.text = languages[indexPath.row - 1].language
		}
		return cell!
	}

	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let index = indexPath.row
		if index == 0 {
			Settings.sharedInstance.currentLanguage = ""
		} else {
			Settings.sharedInstance.currentLanguage = languages[index - 1].language
		}

		doneClosure()

		self.navigationController?.popViewControllerAnimated(true)

//		self.dismissViewControllerAnimated(true, completion: {
//			self.closure()
//		})

	}

	// MARK: - IBActions -

	@IBAction func languageSelection(sender: UISegmentedControl) {
		Settings.sharedInstance.onlyFavoriteLanguages = (sender.selectedSegmentIndex == 0)
		tableView.reloadData()

	}
}
