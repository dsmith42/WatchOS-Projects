//
//  WorkoutInterfaceController.swift
//  iMove WatchKit Extension
//
//  Created by Dan Smith on 20/03/2021.
//

import WatchKit
import Foundation


class WorkoutInterfaceController: WKInterfaceController {

	@IBOutlet var quantityLabel: WKInterfaceLabel!
	@IBOutlet var unitLabel: WKInterfaceLabel!
	@IBOutlet var stopButton: WKInterfaceButton!
	@IBOutlet var resumeButton: WKInterfaceButton!
	@IBOutlet var endButton: WKInterfaceButton!

	override func awake(withContext context: Any?) {
		super.awake(withContext: context)

		// Configure interface objects here.
	}

	override func willActivate() {
		// This method is called when watch view controller is about to be visible to user
		super.willActivate()
	}

	override func didDeactivate() {
		// This method is called when watch view controller is no longer visible
		super.didDeactivate()
	}

	@IBAction func changeDisplayMode() {
	}

	@IBAction func stopWorkout() {
	}

	@IBAction func resumeWorkout() {
	}
	
	@IBAction func endWorkout() {
	}

}
