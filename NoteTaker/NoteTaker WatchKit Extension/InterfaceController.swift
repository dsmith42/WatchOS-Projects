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

	private var notes = [String]()
	private var savePath = InterfaceController.getDocumentsDirectory().appendingPathComponent("notes")

	override func awake(withContext context: Any?) {

		do {
			let data = try Data(contentsOf: savePath)
			notes = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [String] ?? [String]()
		} catch {
			// do nothing notes is already an empty array
		}

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
		// 1 - request user input
		presentTextInputController(withSuggestions: nil, allowedInputMode: .plain) { [unowned self] result in

			// 2 - conver the result to a string or return
			guard let newNote = result?.first as? String else { return }

			// 3 - insert a new row at the end of our table
			self.table.insertRows(at: IndexSet(integer: self.notes.count), withRowType: "Row")

			// 4 - give the row the correct text
			self.set(row: self.notes.count, to: newNote)

			// 5 - append the new note to our array
			self.notes.append(newNote)

			// 6 - archive notes
			self.saveNote()
		}
	}

	private func saveNote() {
		do {
			let data = try NSKeyedArchiver.archivedData(withRootObject: self.notes, requiringSecureCoding: false)
			try data.write(to: self.savePath)
		} catch {
			print("Failed to save data: \(error.localizedDescription).")
		}
	}

	override func contextForSegue(withIdentifier segueIdentifier: String, in table: WKInterfaceTable, rowIndex: Int) -> Any? {
		return ["index": String(rowIndex + 1), "note": notes[rowIndex]]
	}

	// NB: WatchOS app only ever has one docs directory but it will still be stored
	//     in an array
	static func getDocumentsDirectory() -> URL {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

		return paths[0]
	}
}
