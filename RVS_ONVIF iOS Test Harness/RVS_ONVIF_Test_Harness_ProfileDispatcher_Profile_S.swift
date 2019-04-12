//
//  RVS_ONVIF_Test_Harness_ProfileDispatcher_Core.swift
//  RVS_ONVIF Test Harness
//
//  Created by Chris Marshall on 3/6/19.
//  Copyright © 2019 The Great Rift Valley Software Company. All rights reserved.
//

import UIKit
import RVS_ONVIF_iOS

class RVS_ONVIF_Test_Harness_ProfileDispatcher_Profile_S: RVS_ONVIF_Test_Harness_ProfileDispatcherProtocol, RVS_ONVIF_Profile_SDelegate {
    /* ################################################################## */
    /**
     */
    var profileObject: ProfileHandlerProtocol!

    /* ################################################################## */
    /**
     */
    var owner: RVS_ONVIF_Test_Harness_Functions_TableViewController!

    /* ################################################################## */
    /**
     */
    var oldDelegate: RVS_ONVIFDelegate!
    
    /* ################################################################## */
    /**
     */
    func updateUI() {
        
    }

    /* ################################################################## */
    /**
     */
    init(profile inProfile: ProfileHandlerProtocol, owner inOwner: RVS_ONVIF_Test_Harness_Functions_TableViewController) {
        profileObject = inProfile
        owner = inOwner
    }

    /* ################################################################## */
    /**
     */
    @objc func simpleCallFromButton(_ inButton: UIButton) {
        let deviceRequestName = inButton.title(for: .normal)
        let commands = profileObject?.availableCommands.filter {
            $0.rawValue == deviceRequestName
        }
        
        if 1 == commands?.count, let command = commands?[0] {
            owner.simpleCall(command)
        }
    }

    /* ################################################################## */
    /**
     */
    func tableView(_ inTableView: UITableView, heightForRowAt inIndexPath: IndexPath) -> CGFloat {
        return 30
    }

    /* ################################################################## */
    /**
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let command = profileObject.availableCommandsAsStrings[indexPath.row]
        
        switch command {
        default:
            if profileObject.availableCommands[indexPath.row].requiresParameters {
                if let ret = tableView.dequeueReusableCell(withIdentifier: RVS_ONVIF_Test_Harness_Functions_TableViewController.textOnlyCellID) {
                    ret.textLabel?.text = command
                    return ret
                }
            } else if let ret = tableView.dequeueReusableCell(withIdentifier: RVS_ONVIF_Test_Harness_Functions_TableViewController.buttonOnlyCellID) as? RVS_ONVIF_Test_Harness_Functions_ButtonOnly_TableViewCell {
                ret.button?.setTitle(command, for: .normal)
                ret.button?.addTarget(self, action: #selector(simpleCallFromButton), for: .touchUpInside)
                return ret
            }
        }
        return UITableViewCell()
    }
    
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, simpleResponseToRequest inSimpleResponseToRequest: RVS_ONVIF_DeviceRequestProtocol!) {
    }
    
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, failureWithReason inReason: RVS_ONVIF.RVS_Fault!) {
        oldDelegate.onvifInstance(inONVIFInstance, failureWithReason: inReason)
    }
    
    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getVideoSourceConfigurations inConfigurationsArray: [RVS_ONVIF_Profile_S.VideoSourceConfiguration]) {
        #if DEBUG
            print("Video Source Configurations Capabilities: \(String(describing: inConfigurationsArray))")
        #endif
        if let destination = owner?.storyboard?.instantiateViewController(withIdentifier: "GetVideoSourceConfigurations") as? RVS_ONVIF_Test_Harness_VideoSourceConfigurations_TableViewController {
            destination.onvifInstance = owner?.onvifInstance
            destination.configurationRows = inConfigurationsArray
            owner?.navigationController?.show(destination, sender: nil)
        }
    }

    /* ################################################################## */
    /**
     */
    func onvifInstance(_ inONVIFInstance: RVS_ONVIF, getProfiles inProfileArray: [RVS_ONVIF_Profile_S.Profile]) {
        #if DEBUG
            print("Profiles: \(String(describing: inProfileArray))")
        #endif
        if let destination = owner?.storyboard?.instantiateViewController(withIdentifier: "GetProfiles") as? RVS_ONVIF_Test_Harness_Profiles_TableViewController {
            destination.onvifInstance = owner?.onvifInstance
            destination.profileArray = inProfileArray
            owner?.navigationController?.show(destination, sender: nil)
        }
    }
}
