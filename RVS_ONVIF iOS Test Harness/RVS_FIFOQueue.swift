/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 
 Version 1.0
 */

import Foundation

/* ###################################################################################################################################### */
/**
 This was taken straight from the objc.io book "Advanced Swift." It's so damn useful, that we should have it as a standard tool.

 A type that can efficiently "enqueue" and "dequeue" elements. It works on one element at a time. You cannot dequeue groups of elements.
 */
protocol Queue {
    /* ################################################################## */
    /**
     Defines the type for the Elements
     */
    associatedtype Element
    
    /* ################################################################## */
    /**
     Adds a new Element to the end (back) of the queue
     */
    mutating func enqueue(_ element: Element)
    
    /* ################################################################## */
    /**
     Removes and returns the first element from the beginning (front) of the queue. nil, if the queue is empty.
     */
    mutating func dequeue() -> Element?
}

/* ###################################################################################################################################### */
/**
 An efficient variable-size FIFO queue of elements of type "Element."
 */
struct RVS_FIFOQueue<Element>: Queue {
    private var _leftQueue: [Element] = []
    private var _rightQueue: [Element] = []
    
    /* ################################################################## */
    /**
     Add an Element to the end of the queue.
     - parameter inNewElement: The Element to be enqueued (placed on the end of the list).
     - Complexity: O(1).
     */
    mutating func enqueue(_ inNewElement: Element) {
        _rightQueue.append(inNewElement)
    }
    
    /* ################################################################## */
    /**
     Removes and returns from the front of the queue.
     Returns nil for an empty queue.
     - returns: The first Element
     - Complexity: Amortized O(1).
     The "Amortized" is because there's a one-time "charge" for dumping the right queue into the left queue.
     The way that this works, is that the right queue is a "staging" queue. It's cheap to shove elements onto the top.
     We remove elements from the top of the left queue, so there's no moving of memory.
     When the left queue is empty, we dump the entire right (staging) queue into it, as reversed.
     The idea is to keep all the operations on the tops of the queues. That prevents massive memory movements every time we access the bottom.
     */
    mutating func dequeue() -> Element? {
        if _leftQueue.isEmpty { // If we are empty, then we simply dump the right queue into the left queue, all at once, as reversed.
            _leftQueue = _rightQueue.reversed()
            _rightQueue.removeAll()
        }
        return _leftQueue.popLast() // Since we are popping off the top, the cost is negligible.
    }
}

/* ###################################################################################################################################### */
/**
 We add the initializer with a variadic parameter list of type "Element."
 */
extension RVS_FIFOQueue: ExpressibleByArrayLiteral {
    /* ################################################################## */
    /**
     Variadic initializer.
     */
    public init(arrayLiteral inElements: Element...) {
        _leftQueue = inElements.reversed()
        _rightQueue = []
    }
}

/* ###################################################################################################################################### */
/**
 */
extension RVS_FIFOQueue: MutableCollection {
    /* ################################################################## */
    /**
     - returns: 0. The start is always 0.
     */
    public var startIndex: Int {
        return 0
    }
    
    /* ################################################################## */
    /**
     - returns: The length of both internal queues, combined.
     */
    public var endIndex: Int {
        return _leftQueue.count + _rightQueue.count
    }
    
    /* ################################################################## */
    /**
     - parameter after: The index we want to get after.
     
     - retruns: The input plus one (Can't get simpler than that).
     */
    public func index(after inIndex: Int) -> Int {
        return inIndex + 1
    }
    
    /* ################################################################## */
    /**
     - parameter position: The position of the element we are working on.
     
     - returns: The element we are subscripting.
     */
    public subscript(position: Int) -> Element {
        get {
            precondition((0..<endIndex).contains(position), "Index out of bounds")
            // See which queue the element is in.
            if position < _leftQueue.endIndex {
                return _leftQueue[_leftQueue.count - position - 1]
            } else {
                return _rightQueue[position - _leftQueue.count]
            }
        }
        
        set {
            precondition((0..<endIndex).contains(position), "Index out of bounds")
            if position < _leftQueue.endIndex {
                _leftQueue[_leftQueue.count - position - 1] = newValue
            } else {
                return _rightQueue[position - _leftQueue.count] = newValue
            }
        }
    }
}
