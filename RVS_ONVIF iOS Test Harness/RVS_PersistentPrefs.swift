/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 
 Version 1.0
*/

import Foundation

/* ################################################################################################################################## */
/**
 This is a "persistent defaults" class (not a struct -we want this to be by reference). It uses the app standard userDefaults mechanism
 for saving and retrieving a Dictionary<String, Any>.
 */
class RVS_PersistentPrefs {
    /* ############################################################################################################################## */
    // MARK: - Private Instance Properties
    /* ############################################################################################################################## */
    /**
     I make these implicitly unwrapped optionals on purpose. I want this puppy to crash if it's in bad shape.
     */
    /* ################################################################## */
    /**
     */
    private let _defaultKeys: [String]!
    
    /* ################################################################## */
    /**
     */
    private var _values: [String: Any]!
    
    /* ################################################################## */
    /**
     */
    private let _tag: String!

    /* ############################################################################################################################## */
    // MARK: - Private Instance Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This simply takes a snapshot of all the text fields, and saves them in the app defaults container.
     */
    private func _saveState() {
        let defaults = UserDefaults.standard
        
        if let _defaults = _defaultKeys {
            var savingPrefs: [String: Any] = [:]
            
            // Read in the defaults that we saved.
            for key in _defaults {
                savingPrefs[key] = defaults.object(forKey: key)
            }

            for valuePair in _values {
                savingPrefs[valuePair.key] = valuePair.value
            }
            
            #if DEBUG
                print("saving Prefs: \(savingPrefs)")
            #endif
            
            UserDefaults.standard.set(savingPrefs, forKey: _tag)
        }
    }
    
    /* ################################################################## */
    /**
     This reads anything in the app defaults container, and applies them to set up the text fields.
     */
    private func _loadState() {
        if let loadedPrefs = UserDefaults.standard.object(forKey: _tag) as? [String: Any] {
            #if DEBUG
                print("Loaded Prefs: \(loadedPrefs)")
            #endif
            
            let defaults = UserDefaults.standard
            
            if let _defaults = _defaultKeys {
                var newPrefs: [String: Any] = [:]
                
                // Read in the defaults that we saved. This ensures that we get all the various
                for key in _defaults {
                    newPrefs[key] = defaults.object(forKey: key)
                }

                // Update the defaults with what we saved the last time.
                for valuePair in loadedPrefs {
                    newPrefs[valuePair.key] = valuePair.value
                }
                
                _values = newPrefs
            }
        }
    }
    
    /* ############################################################################################################################## */
    // MARK: - Private Instance Initializer
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     This is private to prevent this struct from being instantiated in an undefined state.
     */
    private init(_defaults inDefaults: [String: Any] = [:], _tag inTag: String = "", _values inValues: [String: Any] = [:]) {
        _defaultKeys = nil
        _tag = nil
        _values = nil
    }

    /* ############################################################################################################################## */
    // MARK: - Public Instance Properties
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    var values: [String: Any]! {
        get {
            _loadState()
            return _values
        }
        
        set {
            _values = newValue
            _saveState()
        }
    }
    
    /* ############################################################################################################################## */
    // MARK: - Public Instance Initializer
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     */
    init(tag inTag: String, values inValues: [String: Any]) {
        _tag = inTag
        _values = inValues
        _defaultKeys = Array(inValues.keys)
        
        #if DEBUG
            print("Default Prefs: \(String(describing: _values))")
        #endif

        UserDefaults.standard.register(defaults: _values)
    }
    
    /* ################################################################## */
    /**
     */
    public subscript(_ inStringKey: String) -> Any! {
        get {
            if let values = values, let value = values[inStringKey] {
                return value
            }
            return nil
        }
        
        set {
            if nil != newValue {
                self.values[inStringKey] = newValue
            } else {
                if var values = values {
                    values.removeValue(forKey: inStringKey)
                    self.values = values
                }
            }
        }
    }
}
