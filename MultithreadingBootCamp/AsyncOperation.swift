//
//  AsyncOperation.swift
//  MultithreadingBootCamp
//
//  Created by Rijo Samuel on 26/12/21.
//

import Foundation

class AsyncOperation: Operation {
	
	private let lockQueue = DispatchQueue(label: "com.cocoaheads.nl")
	
	override var isAsynchronous: Bool { true }
	
	private var _isExecuting: Bool = false
	private var _isFinished: Bool = false
	
	override var isExecuting: Bool {
		get {
			lockQueue.sync { _isExecuting }
		}
		set {
			willChangeValue(forKey: "isExecuting")
			lockQueue.sync { _isExecuting = newValue }
			didChangeValue(forKey: "isExecuting")
		}
	}
	
	override var isFinished: Bool {
		get {
			lockQueue.sync { _isFinished }
		}
		set {
			willChangeValue(forKey: "isFinished")
			lockQueue.sync { _isFinished = newValue }
			didChangeValue(forKey: "isFinished")
		}
	}
	
	override func start() {
		isFinished = false
		isExecuting = true
		main()
	}
	
	override func main() {
		
		guard !isCancelled else { return }
		
		DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
			print("Perform Operation")
			self.finish()
		}
	}
	
	func finish() {
		isExecuting = false
		isFinished = true
	}
}


final class AsyncResultOperation<Success, Failure>: AsyncOperation where Failure: Error {
	
	private(set) var result: Result<Success, Failure>? {
		didSet {
			
			guard let result = result else { return }

			onResult?(result)
		}
	}
	
	var onResult: ((_ result: Result<Success, Failure>) -> Void)?
	
	override func finish() {
		fatalError("You should use finish(with:) to ensure a result")
	}
	
	func finish(with result: Result<Success, Failure>) {
		self.result = result
		super.finish()
	}
	
	override func cancel() {
		fatalError("You should use cancel(with:) to ensure a result")
	}
	
	func cancel(with error: Failure) {
		result = .failure(error)
		super.cancel()
	}
}
