//
//  InterfaceController.swift
//  iMove WatchKit Extension
//
//  Created by Dan Smith on 20/03/2021.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

	@IBOutlet var activityType: WKInterfacePicker!

	override func awake(withContext context: Any?) {
		// Configure interface objects here.
	}

	override func willActivate() {
		// This method is called when watch view controller is about to be visible to user
	}

	override func didDeactivate() {
		// This method is called when watch view controller is no longer visible
	}

	@IBAction func activityPickerChanged(_ value: Int) {
	}
	
	@IBAction func startWorkoutTapped() {
	}
	
}
