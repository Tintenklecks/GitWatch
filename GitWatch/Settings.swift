//
//  SettingsManager.swift
//  SwiftSettingsManager
//
//  Created by Prashant on 03/09/15.
//  Copyright (c) 2015 PrashantKumar Mangukiya. All rights reserved.
//

import Foundation
import UIKit

var standardStorage = NSUserDefaults.standardUserDefaults()

class Settings {

	// MARK: - SINGLETON -

	// setup shared instance
	class var sharedInstance: Settings {
		struct Static {
			static let instance: Settings = Settings()
		}
		return Static.instance
	}

	// get default storage
	private var defaultStorage = NSUserDefaults.standardUserDefaults()

	// Define derived property for all Key/Value settings.

	// MARK: - PERSISTANT SETTINGS VARS -

	// should the trips be shown with newest trip first?
	var currentLanguage: String {
		get {
			return Settings.getString("currentLanguage", defaultValue: "Swift")
		} set {
			Settings.setString("currentLanguage", value: newValue)
		}
	}

	var onlyWithDescription: Bool {
		get {
			return Settings.getBool("onlyWithDescription", defaultValue: true)
		} set {
			Settings.setBool("onlyWithDescription", value: newValue)
		}
	}

	var onlyFavoriteLanguages: Bool {
		get {
			return Settings.getBool("onlyFavoriteLanguages", defaultValue: true)
		} set {
			Settings.setBool("onlyFavoriteLanguages", value: newValue)
		}
	}

	var fetchAmount: Int { // number of records to fetch from GITHUB
		get {
			return Settings.getInt("fetchAmount", defaultValue: 30)
		} set {
			Settings.setInt("fetchAmount", value: newValue)
		}
	}

	// Summy Double value

	var dummyDouble: Double {
		get {
			return Settings.getDouble("dummyDouble", defaultValue: 8.0)
		} set {
			Settings.setDouble("dummyDouble", value: newValue)
		}
	}

	// MARK: - Default Settings GETTER -

	// Integer Value

	class func getInt(key: String, defaultValue: Int = 0) -> Int {
		if standardStorage.objectForKey(key) != nil {
			let returnValue = standardStorage.objectForKey(key) as! Int
			return returnValue
		} else {
			return defaultValue // default value
		}
	}

	// Double Value

	class func getDouble(key: String, defaultValue: Double = 0.0) -> Double {
		if standardStorage.objectForKey(key) != nil {
			let returnValue = standardStorage.objectForKey(key) as! Double
			return returnValue
		} else {
			return defaultValue // default value
		}
	}

	// Bool Value

	class func getBool(key: String, defaultValue: Bool = false) -> Bool {
		if standardStorage.objectForKey(key) != nil {
			let returnValue = standardStorage.objectForKey(key) as! Bool
			return returnValue
		} else {
			return defaultValue // default value
		}
	}

	// String Value

	class func getString(key: String, defaultValue: String = "") -> String {
		if standardStorage.objectForKey(key) != nil {
			let returnValue = standardStorage.objectForKey(key) as! String
			return returnValue
		} else {
			return defaultValue // default value
		}
	}

	// MARK: - Default Settings SETTER -

	class func setInt(key: String, value: Int) {
		standardStorage.setInteger(value, forKey: key)
	}

	class func setDouble(key: String, value: Double) {
		standardStorage.setDouble(value, forKey: key)
	}

	class func setBool(key: String, value: Bool) {
		standardStorage.setBool(value, forKey: key)
	}

	class func setString(key: String, value: String) {
		standardStorage.setObject(value, forKey: key)
	}

}
