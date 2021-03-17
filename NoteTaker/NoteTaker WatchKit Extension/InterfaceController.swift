//
//  InterfaceController.swift
//  NoteTaker WatchKit Extension
//
//  Created by Dan Smith on 17/03/2021.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

	@IBOutlet var table: WKInterfaceTable!

	private var notes: [String] = ["Hello", "Dan", "How", "Are", "You?"]
	override func awake(withContext context: Any?) {
		// Configure interface objects here.
		table.setNumberOfRows(notes.count, withRowType: "Row")

		for rowIndex in 0..<notes.count {
			set(row: rowIndex, to: notes[rowIndex])
		}
	}

	private func set(row rowIndex: Int, to text: String) {
		guard let row = table.rowController(at: rowIndex) as? NoteSelectRow else { return }
		row.textLabel.setText(text)
	}

	override func willActivate() {
		// This method is called when watch view controller is about to be visible to user
	}

	override func didDeactivate() {
		// This method is called when watch view controller is no longer visible
	}

	@IBAction func addButtonTapped() {

	}
}
