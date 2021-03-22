//
//  WorkoutInterfaceController.swift
//  iMove WatchKit Extension
//
//  Created by Dan Smith on 20/03/2021.
//

import WatchKit
import Foundation
import HealthKit

enum DisplayMode {
	case distance, energy, heartRate
}

class WorkoutInterfaceController: WKInterfaceController {

	@IBOutlet var quantityLabel: WKInterfaceLabel!
	@IBOutlet var unitLabel: WKInterfaceLabel!
	@IBOutlet var stopButton: WKInterfaceButton!
	@IBOutlet var resumeButton: WKInterfaceButton!
	@IBOutlet var endButton: WKInterfaceButton!

	var healthStore: HKHealthStore?
	var distanceType = HKQuantityTypeIdentifier.distanceWalkingRunning
	var workoutStartDate = Date()
	var activeDataQueries = [HKQuery]()
	var workoutSession: HKWorkoutSession?
	var totalEnergyBurned = HKQuantity(unit: .kilocalorie(), doubleValue: 0)
	var totalDistance = HKQuantity(unit: .meter(), doubleValue: 0)
	var lastHearRate = 0.0
	let countPerMinuteUnit = HKUnit(from: "count/min")
	var displayMode: DisplayMode = .distance
	var workoutIsActive = true
	var workoutEndDate = Date()

	override func awake(withContext context: Any?) {
		super.awake(withContext: context)

		guard let activity = context as? HKWorkoutActivityType else { return }
		setDistanceType(for: activity)

		// configure the values we want to write to HealthKit
		let writeTypes: Set<HKSampleType> = [
			.workoutType(),
			HKSampleType.quantityType(forIdentifier: .heartRate)!,
			HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)!,
			HKSampleType.quantityType(forIdentifier: distanceType)!
		]

		// configure the values we want to read to HealthKit
		let readTypes: Set<HKObjectType> = [
			.activitySummaryType(),
			.workoutType(),
			HKObjectType.quantityType(forIdentifier: .heartRate)!,
			HKObjectType.quantityType(forIdentifier: .heartRate)!,
			HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
			HKObjectType.quantityType(forIdentifier: distanceType)!
		]

		// create our healthStore
		healthStore = HKHealthStore()

		// request authorization for our types
		healthStore?.requestAuthorization(toShare: writeTypes, read: readTypes) { success, error in

			if success {
				// start workout
				self.startWorkout(activityType: activity)
			}

		}
	}

	func startWorkout(activityType: HKWorkoutActivityType) {
		// create a workout configuration
		let config = HKWorkoutConfiguration()
		config.activityType = activityType
		config.locationType = .outdoor

		// create a workout session
		if let healthStore = healthStore, let session = try? HKWorkoutSession(healthStore: healthStore, configuration: config) {

			workoutSession = session
			workoutStartDate = Date()

			// start the workout now
			workoutSession?.startActivity(with: workoutStartDate)

			// register to receive status updates
			session.delegate = self
		}

	}

	func startQueries() {
		startQuery(distanceType)
		startQuery(.activeEnergyBurned)
		startQuery(.heartRate)
		WKInterfaceDevice.current().play(.start)
	}

	// MARK: - Helper Functions -
	func startQuery(_ quantityTypeIdentifier: HKQuantityTypeIdentifier) {
		// we only want data points after our workout start date
		let datePredicate = HKQuery.predicateForSamples(withStart: workoutStartDate, end: nil, options: .strictStartDate)

		// we only want data points that come from our current device
		let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])

		// combine the two predicates into one
		let queryPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, devicePredicate])

		// write code to recieve results from our query
		let updateHandler = { (query: HKAnchoredObjectQuery,
													 samples: [HKSample]?,
													 deletedObjects: [HKDeletedObject]?,
													 HKQueryAnchor: HKQueryAnchor?,
													 error: Error?) in

			// safely typecast to a quanitity sample so we can read values
			guard let samples = samples as? [HKQuantitySample] else { return }

			self.process(samples, type: quantityTypeIdentifier)
		}

		// create the query out ouf our type (e.g. heart rate), predicate, and result handling code
		let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!,
																			predicate: queryPredicate,
																			anchor: nil,
																			limit: HKObjectQueryNoLimit,
																			resultsHandler: updateHandler)

		// tell HealthKit to re-run the code every time new data is avialable
		query.updateHandler = updateHandler
		healthStore?.execute(query)

		activeDataQueries.append(query)

	}

	private func updateLabels() {
		switch displayMode {
		case .distance:
			let kilometres = totalDistance.doubleValue(for: .meter()) / 1000
			let formattedKM = String(format: "%.2f", kilometres)
			refreshLabels(quantity: formattedKM, units: "KILOMETRES", color: .white)
		case .energy:
			let kilocalories = totalEnergyBurned.doubleValue(for: .kilocalorie())
			let formattedKCal = String(format: "%.0f", kilocalories)
			refreshLabels(quantity: formattedKCal, units: "CALORIES", color: .orange)
		case .heartRate:
			let heartRate = String(Int(lastHearRate))
			refreshLabels(quantity: heartRate, units: "BPM", color: .red)
		}
	}

	private func refreshLabels(quantity: String, units: String, color: UIColor) {
		quantityLabel.setText(quantity)
		quantityLabel.setTextColor(color)
		unitLabel.setText(units)
		unitLabel.setTextColor(color)
	}

	// Process the samples
	func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
		// ignore updates while we are paused
		guard workoutIsActive else { return}

		// loop over all the samples we've been sent
		for sample in samples {

			// Calories
			if type == .activeEnergyBurned {
				// find out how many calories were burned
				let newEnergy = sample.quantity.doubleValue(for: .kilocalorie())

				// get our current totalcalories burned
				let currentEnergy = totalEnergyBurned.doubleValue(for: .kilocalorie())
				totalEnergyBurned = HKQuantity(unit: .kilocalorie(), doubleValue: currentEnergy + newEnergy)

				// debug logging
				print("Total energy: \(totalEnergyBurned)")
			} else if type == .heartRate {
				// we got a heart rate just update the property
				lastHearRate = sample.quantity.doubleValue(for: countPerMinuteUnit)
				print("Last heart rate: \(lastHearRate)")
			} else if type == distanceType {
				// update distance
				let newDistance = sample.quantity.doubleValue(for: .meter())
				let currentDistance = totalDistance.doubleValue(for: .meter())
				totalDistance = HKQuantity(unit: .meter(), doubleValue: currentDistance + newDistance)
				print("Total distance: \(totalDistance)")
			}
		}
		updateLabels()
	}

	override func willActivate() {
		// This method is called when watch view controller is about to be visible to user
		super.willActivate()
	}

	override func didDeactivate() {
		// This method is called when watch view controller is no longer visible
		super.didDeactivate()
	}

	private func setDistanceType(for activity: HKWorkoutActivityType) {
		switch activity {
		case .cycling:
			distanceType = .distanceCycling
		case .swimming:
			distanceType = .distanceSwimming
		default:
			distanceType = .distanceWalkingRunning
		}
	}

	@IBAction func changeDisplayMode() {
		switch displayMode {
		case .distance:
			displayMode = .energy
		case .energy:
			displayMode = .heartRate
		case .heartRate:
			displayMode = .distance
		}
		updateLabels()
	}

	@IBAction func stopWorkout() {
		guard let workoutSession = workoutSession else { return }
		stopButton.setHidden(true)
		resumeButton.setHidden(false)
		endButton.setHidden(false)

		workoutSession.pause()
	}

	@IBAction func resumeWorkout() {
		guard let workoutSession = workoutSession else { return }
		stopButton.setHidden(false)
		resumeButton.setHidden(true)
		endButton.setHidden(true)

		workoutSession.resume()
	}
	
	@IBAction func endWorkout() {
		guard let workoutSession = workoutSession else { return }

		workoutEndDate = Date()
		workoutSession.end()

	}

	func cleanUpQueries() {
		for query in activeDataQueries {
			healthStore?.stop(query)
		}
		activeDataQueries.removeAll()
	}

	func save(_ workoutSession: HKWorkoutSession) {
		let config = workoutSession.workoutConfiguration
		let workout = HKWorkout(activityType: config.activityType,
														start: workoutStartDate,
														end: workoutEndDate,
														workoutEvents: nil,
														totalEnergyBurned: totalEnergyBurned,
														totalDistance: totalDistance,
														metadata: [HKMetadataKeyIndoorWorkout: false])

		healthStore?.save(workout) { (success, error) in
			if success {
				DispatchQueue.main.async {
					WKInterfaceController.reloadRootPageControllers(withNames: ["InterfaceController"],
																													contexts: nil,
																													orientation: .horizontal,
																													pageIndex: 0)
				}
			}
		}
	}
}

extension WorkoutInterfaceController: HKWorkoutSessionDelegate {
	// gets called once initialisation on watch completed
	func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
		switch toState {
		case .running:
			if fromState == .notStarted {
				startQueries()
			} else {
				workoutIsActive = true
			}

		case .paused:
			workoutIsActive = false

		case .ended:
			workoutIsActive = false
			cleanUpQueries()
			save(workoutSession)

		default:
				break
		}
	}

	func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
		
	}
}
