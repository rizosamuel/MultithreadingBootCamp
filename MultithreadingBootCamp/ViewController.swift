//
//  ViewController.swift
//  MultithreadingBootCamp
//
//  Created by Rijo Samuel on 23/12/21.
//

import UIKit

final class ViewController: UIViewController {
	
	private let queue = OperationQueue()

	override func viewDidLoad() {
		super.viewDidLoad()
		orderOfExecution()
	}


	func orderOfExecution() {
		
		let backgroundOperation = BlockOperation {
			print("Background Operation")
		}
		
		let userTriggeredOperation = BlockOperation {
			print("User Triggered Operation")
		}
		
		queue.addOperations([backgroundOperation, userTriggeredOperation], waitUntilFinished: true)
	}
}
