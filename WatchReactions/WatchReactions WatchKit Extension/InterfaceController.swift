//
//  InterfaceController.swift
//  WatchReactions WatchKit Extension
//
//  Created by Dan Smith on 21/03/2021.
//

import WatchKit
import AVFoundation


class InterfaceController: WKInterfaceController, SoundPlaying {
	var audioPlayer: AVAudioPlayer?
	
	override func awake(withContext context: Any?) {
		// Configure interface objects here.
	}

	override func willActivate() {
		// This method is called when watch view controller is about to be visible to user
	}

	override func didDeactivate() {
		// This method is called when watch view controller is no longer visible
	}

	@IBAction func playSound1() {
		playSound(named: "mario-coin")
	}

	@IBAction func playSound2() {
		playSound(named: "fail")
	}

	@IBAction func playSound3() {
		playSound(named: "inception-fog")
	}

	@IBAction func playSound4() {
		playSound(named: "nelson-fail")
	}
}
