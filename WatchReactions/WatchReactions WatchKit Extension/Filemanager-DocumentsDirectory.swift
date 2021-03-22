//
//  Filemanager-DocumentsDirectory.swift
//  WatchReactions WatchKit Extension
//
//  Created by Dan Smith on 22/03/2021.
//

import Foundation

extension FileManager {
	func getDocumentsDirectory() -> URL {
		let paths = urls(for: .documentDirectory, in: .userDomainMask)
		return paths[0]
	}
}
