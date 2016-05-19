//
//  GITREALM.swift
//  GitWatch
//
//  Created by Ingo on 16.05.16.
//  Copyright © 2016 Ingo. All rights reserved.
//

import Foundation
import RealmSwift

class GITRealm: Object {

	dynamic var gitID: Int = 0
	dynamic var repoName: String = "(some Repo Name)"
	dynamic var repoDescription: String = ""
	dynamic var repoURL: String = ""
	dynamic var repoLanguage: String = ""

	dynamic var watchers: Int = 0
	dynamic var stargazers_count: Int = 0
	dynamic var hasWiki: Bool = false

	dynamic var favorite: Bool = false
	dynamic var note: String = ""

	dynamic var updatedAt: String = ""
	dynamic var homepage: String = ""

	override static func primaryKey() -> String? {
		return "gitID"
	}

	override static func indexedProperties() -> [String] {
		return ["repoLanguage", "repoName", "watchers", "stargazers_count"]
	}

	// override static func ignoredProperties() -> [String] {
	// return []
	// }
}

class LanguagesRealm: Object {

	dynamic var language: String = ""
	dynamic var topLanguage: Bool = false

	override static func primaryKey() -> String? {
		return "language"
	}

//	override static func indexedProperties() -> [String] {
//		return ["repoLanguage", "repoName", "watchers", "stargazers_count"]
//	}
//
	// override static func ignoredProperties() -> [String] {
	// return []
	// }
}
