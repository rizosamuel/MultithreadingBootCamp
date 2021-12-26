//
//  ViewController.swift
//  MultithreadingBootCamp
//
//  Created by Rijo Samuel on 23/12/21.
//

import UIKit

final class ViewController: UIViewController {
	
	private let operationQueue: OperationQueue
	private let dispatchQueue: DispatchQueue
	private let dispatchGroup: DispatchGroup
	private let dispatchSemaphore: DispatchSemaphore
	
	private var movies: [String] = []
	
	init() {
		
		self.operationQueue = OperationQueue()
		self.dispatchQueue = DispatchQueue.global()
		self.dispatchGroup = DispatchGroup()
		self.dispatchSemaphore = DispatchSemaphore(value: 1)
		super.init()
	}
	
	required init?(coder: NSCoder) {
		
		self.operationQueue = OperationQueue()
		self.dispatchQueue = DispatchQueue.global()
		self.dispatchGroup = DispatchGroup()
		self.dispatchSemaphore = DispatchSemaphore(value: 1)
		super.init(coder: coder)
		// fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		// orderOfExecution()
		// importContent()
		// dependentOperations()
		// asyncOperation()
		startDispatch()
	}
	
	private func orderOfExecution() {
		
		let backgroundOperation = BlockOperation {
			
			print("Background Operation running")
			sleep(2)
			print("Background Operation completed")
		}
		
		let userTriggeredOperation = BlockOperation {
			
			print("User Triggered Operation running")
			sleep(2)
			print("User Triggered Operation completed")
		}
		
		// userTriggeredOperation.queuePriority = .veryHigh
		userTriggeredOperation.qualityOfService = .userInitiated
		operationQueue.addOperations([backgroundOperation, userTriggeredOperation], waitUntilFinished: true)
	}
	
	private func importContent() {
		
		let fileURL = URL(fileURLWithPath: "")
		let itemProvider = NSItemProvider(contentsOf: fileURL)!
		let contentImportOperation = ContentImportOperation(itemProvider: itemProvider)
		
		contentImportOperation.completionBlock = {
			print("Importing Completed")
		}
		
		operationQueue.addOperation(contentImportOperation)
	}
	
	private func dependentOperations() {
		
		let importOperation = BlockOperation {
			
			print("Import Operation running")
			sleep(2)
			print("Import Operation completed")
		}
		
		let exportOperation = BlockOperation {
			
			print("Export Operation running")
			sleep(2)
			print("Export Operation completed")
		}
		
		exportOperation.addDependency(importOperation)
		operationQueue.addOperations([exportOperation, importOperation], waitUntilFinished: true)
	}
	
	private func asyncOperation() {
		
		let operation = AsyncOperation()
		
		operation.completionBlock = {
			print("Operation completed")
		}
		
		operationQueue.addOperations([operation], waitUntilFinished: true)
	}
	
	private func startDispatch() {
		
		dispatchQueue.async(group: dispatchGroup) {
			
			self.dispatchSemaphore.wait()
			let movieName = self.downloadMovie("Avengers")
			print("This is the queue block \(movieName)")
			self.movies.append(movieName)
			self.dispatchSemaphore.signal()
		}
		
		dispatchQueue.async(group: dispatchGroup) {
			
			self.dispatchSemaphore.wait()
			self.saveMovies()
			self.movies.remove(at: 0)
			self.dispatchSemaphore.signal()
		}
		
		dispatchGroup.notify(queue: .main) {
			print("All movies have finished downloading")
		}
		
		print("This is outside the queue block")
	}
	
	private func downloadMovie(_ name: String) -> String {
		
		print("\(name) is being downloaded")
		sleep(4)
		print("\(name) download complete")
		return name
	}
	
	private func saveMovies() {
		
		print("Saving movies...")
		sleep(2)
		print("Movies have been saved")
	}
}
