//
//  InterfaceController.swift
//  iMove WatchKit Extension
//
//  Created by Dan Smith on 20/03/2021.
//

import WatchKit
import Foundation
import HealthKit

class InterfaceController: WKInterfaceController {

	@IBOutlet var activityType: WKInterfacePicker!

	let activites: [(String, HKWorkoutActivityType)] = [
		("Walking", .walking),
		("Cycling", .cycling),
		("Runnning", .running),
		("Swimming", .swimming)
	]

	var selectedActivity = HKWorkoutActivityType.walking

	override func awake(withContext context: Any?) {
		var items = [WKPickerItem]()

		for activiy in activites {
			let item = WKPickerItem()
			item.title = activiy.0
			items.append(item)
		}

		activityType.setItems(items)
	}

	override func willActivate() {
		// This method is called when watch view controller is about to be visible to user
	}

	override func didDeactivate() {
		// This method is called when watch view controller is no longer visible
	}

	@IBAction func activityPickerChanged(_ value: Int) {
		selectedActivity = activites[value].1
	}
	
	@IBAction func startWorkoutTapped() {
		guard HKHealthStore.isHealthDataAvailable() else { return	}

		WKInterfaceController.reloadRootControllers(withNames: ["WorkoutInterfaceControler"], contexts: [selectedActivity])
	}
	
}
