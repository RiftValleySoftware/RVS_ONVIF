/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

import XCTest

/* ###################################################################################################################################### */
/**
 Runs tests on a mock AXIS camera.
 */
class RVS_ONVIF_Tests_AxisM5525E_Initializer: RVS_ONVIF_Generic_TestBaseClass {
    /* ############################################################################################################################## */
    // MARK: - RVS_ONVIFDelegate Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     We override the initialization complete callback in order to fulfill our expectation.
     */
    override func onvifInstanceInitialized(_ inONVIFInstance: RVS_ONVIF) {
        evaluateDeviceInformation()
        evaluateServices()
        evaluateGetServiceCapabilities()
        evaluateGetScopes()
        evaluateGetNetworkInterfaces()
        evaluateGetCapabilities()
        expectation.fulfill()
    }
    
    /* ############################################################################################################################## */
    // MARK: - Evaluation Methods -Initialization
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     Evaluate the Device Information Dictionary
     */
    func evaluateDeviceInformation() {
        if let deviceInformation = testTarget.deviceInformation as? [String: String] {
            XCTAssertEqual(5, deviceInformation.count)
            XCTAssertEqual(deviceInformation["Manufacturer"], "AXIS")
            XCTAssertEqual(deviceInformation["Model"], "M5525-E")
            XCTAssertEqual(deviceInformation["FirmwareVersion"], "8.40.1.1")
            XCTAssertEqual(deviceInformation["SerialNumber"], "ACCC8EBECCEA")
            XCTAssertEqual(deviceInformation["HardwareId"], "757")
        } else {
            XCTFail("Device Information Record Missing")
        }
    }
    
    /* ################################################################## */
    /**
     Evaluate the Services Array
     */
    func evaluateServices() {
        if let services = testTarget.services {
            XCTAssertEqual(13, services.count)
            for (key, value) in services {
                XCTAssertFalse(key.isEmpty)
                XCTAssertEqual(value.owner, testTarget)
                if let serviceNamespace = value.namespace {
                    XCTAssertEqual(key, serviceNamespace)
                } else {
                    XCTFail("Service Namespace Missing")
                }
                
                if let serviceXAddr = value.xAddr {
                    switch key {
                    case "http://www.onvif.org/ver10/device/wsdl":
                        XCTAssertEqual(URL(string: "http://192.168.4.12/onvif/device_service"), serviceXAddr)
                    case "http://www.onvif.org/ver20/ptz/wsdl":
                        XCTAssertEqual(URL(string: "http://192.168.4.12/onvif/services"), serviceXAddr)
                    case "http://www.onvif.org/ver10/recording/wsdl":
                        XCTAssertEqual(URL(string: "http://192.168.4.12/onvif/services"), serviceXAddr)
                    case "http://www.onvif.org/ver10/search/wsdl":
                        XCTAssertEqual(URL(string: "http://192.168.4.12/onvif/services"), serviceXAddr)
                    case "http://www.onvif.org/ver10/events/wsdl":
                        XCTAssertEqual(URL(string: "http://192.168.4.12/onvif/services"), serviceXAddr)
                    case "http://www.onvif.org/ver10/deviceIO/wsdl":
                        XCTAssertEqual(URL(string: "http://192.168.4.12/onvif/services"), serviceXAddr)
                    case "http://www.axis.com/vapix/ws/certificates":
                        XCTAssertEqual(URL(string: "http://192.168.4.12/onvif/services"), serviceXAddr)
                    case "http://www.onvif.org/ver10/replay/wsdl":
                        XCTAssertEqual(URL(string: "http://192.168.4.12/onvif/services"), serviceXAddr)
                    case "http://www.onvif.org/ver10/media/wsdl":
                        XCTAssertEqual(URL(string: "http://192.168.4.12/onvif/services"), serviceXAddr)
                    case "http://www.axis.com/vapix/ws/entry":
                        XCTAssertEqual(URL(string: "http://192.168.4.12/onvif/services"), serviceXAddr)
                    case "http://www.axis.com/vapix/ws/event1":
                        XCTAssertEqual(URL(string: "http://192.168.4.12/onvif/services"), serviceXAddr)
                    case "http://www.axis.com/vapix/ws/action1":
                        XCTAssertEqual(URL(string: "http://192.168.4.12/onvif/services"), serviceXAddr)
                    case "http://www.axis.com/vapix/ws/webserver":
                        XCTAssertEqual(URL(string: "http://192.168.4.12/onvif/services"), serviceXAddr)
                    default:
                        XCTFail("Unknown Service")
                    }
                } else {
                    XCTFail("Service XAddr Missing")
                }
                
                if let version = value.version {
                    switch key {
                    case "http://www.onvif.org/ver10/device/wsdl":
                        XCTAssertEqual("2.21", version)
                    case "http://www.onvif.org/ver20/ptz/wsdl":
                        XCTAssertEqual("2.41", version)
                    case "http://www.onvif.org/ver10/recording/wsdl":
                        XCTAssertEqual("2.50", version)
                    case "http://www.onvif.org/ver10/search/wsdl":
                        XCTAssertEqual("2.42", version)
                    case "http://www.onvif.org/ver10/events/wsdl":
                        XCTAssertEqual("2.21", version)
                    case "http://www.onvif.org/ver10/deviceIO/wsdl":
                        XCTAssertEqual("2.61", version)
                    case "http://www.axis.com/vapix/ws/certificates":
                        XCTAssertEqual("1.01", version)
                    case "http://www.onvif.org/ver10/replay/wsdl":
                        XCTAssertEqual("2.21", version)
                    case "http://www.onvif.org/ver10/media/wsdl":
                        XCTAssertEqual("2.60", version)
                    case "http://www.axis.com/vapix/ws/entry":
                        XCTAssertEqual("1.01", version)
                    case "http://www.axis.com/vapix/ws/event1":
                        XCTAssertEqual("1.01", version)
                    case "http://www.axis.com/vapix/ws/action1":
                        XCTAssertEqual("1.01", version)
                    case "http://www.axis.com/vapix/ws/webserver":
                        XCTAssertEqual("1.01", version)
                    default:
                        XCTFail("Unknown Service")
                    }
                } else {
                    XCTFail("Service Version Missing")
                }
            }
        } else {
            XCTFail("Services Record Missing")
        }
    }
    
    /* ################################################################## */
    /**
     Evaluate the Service Capabilities Struct
     */
    func evaluateGetServiceCapabilities() {
        if let serviceCapabilities = testTarget.serviceCapabilities {
            XCTAssertEqual(serviceCapabilities.owner, testTarget)
            if let networkCapabilities = serviceCapabilities.networkCapabilities {
                XCTAssertEqual(networkCapabilities.owner, testTarget)
                XCTAssertTrue(networkCapabilities.isDHCPv6)
                XCTAssertTrue(networkCapabilities.isDynDNS)
                XCTAssertTrue(networkCapabilities.isIPVersion6)
                XCTAssertTrue(networkCapabilities.isZeroConfiguration)
                XCTAssertFalse(networkCapabilities.isHostnameFromDHCP)
                XCTAssertFalse(networkCapabilities.isDot11Configuration)
                XCTAssertEqual(1, networkCapabilities.ntp)
            } else {
                XCTFail("Service Network Capabilities Record Missing")
            }
            
            if let securityCapabilities = serviceCapabilities.securityCapabilities {
                XCTAssertEqual(securityCapabilities.owner, testTarget)
                XCTAssertTrue(securityCapabilities.isHttpDigest)
                XCTAssertTrue(securityCapabilities.isUsernameToken)
                XCTAssertTrue(securityCapabilities.isDefaultAccessPolicy)
                XCTAssertTrue(securityCapabilities.isAccessPolicyConfig)
                XCTAssertTrue(securityCapabilities.isOnboardKeyGeneration)
                XCTAssertTrue(securityCapabilities.isTLS10)
                XCTAssertTrue(securityCapabilities.isTLS11)
                XCTAssertTrue(securityCapabilities.isTLS12)
                XCTAssertFalse(securityCapabilities.isRemoteUserHandling)
                XCTAssertFalse(securityCapabilities.isX509Token)
                XCTAssertFalse(securityCapabilities.isSAMLToken)
                XCTAssertFalse(securityCapabilities.isKerberosToken)
                XCTAssertFalse(securityCapabilities.isRELToken)
                XCTAssertNil(securityCapabilities.supportedEAPMethods)
                XCTAssertNil(securityCapabilities.maxUsers)
                XCTAssertNil(securityCapabilities.maxUserNameLength)
                XCTAssertNil(securityCapabilities.maxPasswordLength)
            } else {
                XCTFail("Service Security Capabilities Record Missing")
            }
            
            if let systemCapabilities = serviceCapabilities.systemCapabilities {
                XCTAssertEqual(systemCapabilities.owner, testTarget)
                XCTAssertTrue(systemCapabilities.isDiscoveryResolve)
                XCTAssertTrue(systemCapabilities.isDiscoveryBye)
                XCTAssertTrue(systemCapabilities.isSystemLogging)
                XCTAssertFalse(systemCapabilities.isRemoteDiscovery)
                XCTAssertFalse(systemCapabilities.isSystemBackup)
                XCTAssertFalse(systemCapabilities.isFirmwareUpgrade)
                XCTAssertFalse(systemCapabilities.isHttpFirmwareUpgrade)
                XCTAssertFalse(systemCapabilities.isHttpSystemBackup)
                XCTAssertFalse(systemCapabilities.isHttpSystemLogging)
                XCTAssertFalse(systemCapabilities.isHttpSupportInformation)
                XCTAssertFalse(systemCapabilities.isStorageConfiguration)
                XCTAssertNil(systemCapabilities.maxStorageConfigurations)
                XCTAssertNil(systemCapabilities.geoLocationEntries)
                XCTAssertNil(systemCapabilities.autoGeo)
                XCTAssertNil(systemCapabilities.storageTypesSupported)
            } else {
                XCTFail("Service System Capabilities Record Missing")
            }
            
            XCTAssertNil(serviceCapabilities.auxiliaryCommands)
        } else {
            XCTFail("Service Capabilities Record Missing")
        }
    }
    
    /* ################################################################## */
    /**
     Evaluate the Scopes Array
     */
    func evaluateGetScopes() {
        if let scopes = testTarget.scopes {
            for scope in scopes {
                XCTAssertEqual(scope.owner, testTarget)
                if case let RVS_ONVIF_Core.Scope.Category.Location(location) = scope.category {
                    XCTAssertEqual("", location)
                    XCTAssertTrue(scope.isConfigurable)
                } else if case let RVS_ONVIF_Core.Scope.Category.Profile(profile) = scope.category {
                    switch profile {
                    case let .S(alt):
                        XCTAssertEqual("Streaming", alt)
                    case let .G(alt):
                        XCTAssertEqual("G", alt)
                    default:
                        XCTFail("Unknown Profile")
                    }
                    XCTAssertFalse(scope.isConfigurable)
                } else if case let RVS_ONVIF_Core.Scope.Category.Hardware(hardware) = scope.category {
                    XCTAssertEqual("M5525-E", hardware)
                    XCTAssertFalse(scope.isConfigurable)
                } else if case let RVS_ONVIF_Core.Scope.Category.Name(name) = scope.category {
                    XCTAssertEqual("AXIS M5525-E", name)
                    XCTAssertFalse(scope.isConfigurable)
                } else {
                    XCTFail("Unknown Category")
                }
            }
        } else {
            XCTFail("Scopes Array Missing")
        }
    }
    
    /* ################################################################## */
    /**
     Evaluate the Network Interfaces Struct
     */
    func evaluateGetNetworkInterfaces() {
        if let networkInterfaces = testTarget.networkInterfaces {
            XCTAssertEqual(1, networkInterfaces.count)
            for networkInterface in networkInterfaces {
                XCTAssertEqual(networkInterface.owner, testTarget)
                XCTAssertEqual(networkInterface.token, "")
                XCTAssertTrue(networkInterface.isEnabled)
                XCTAssertEqual(networkInterface.info.name, "eth0")
                XCTAssertEqual(networkInterface.info.hwAddress, "AC:CC:8E:BE:CC:EA")
                XCTAssertEqual(networkInterface.info.mtu, 1500)
                XCTAssertEqual(networkInterface.link.interfaceType, .ethernetCsmacd)
                XCTAssertEqual(networkInterface.link.adminSettings.owner, testTarget)
                XCTAssertTrue(networkInterface.link.adminSettings.autoNegotiation)
                XCTAssertEqual(networkInterface.link.adminSettings.speed, 100)
                XCTAssertEqual(networkInterface.link.adminSettings.duplex, .Full)
                XCTAssertEqual(networkInterface.link.operSettings.owner, testTarget)
                XCTAssertTrue(networkInterface.link.operSettings.autoNegotiation)
                XCTAssertEqual(networkInterface.link.operSettings.speed, 100)
                XCTAssertEqual(networkInterface.link.operSettings.duplex, .Full)
            }
        }
    }
    
    /* ################################################################## */
    /**
     Evaluate the Network Interfaces Struct
     */
    func evaluateGetCapabilities() {
        if let capabilities = testTarget.capabilities {
            XCTAssertEqual(capabilities.owner, testTarget)
            XCTAssertEqual(capabilities.deviceCapabilities.owner, testTarget)
            XCTAssertEqual(capabilities.deviceCapabilities.xAddr, URL(string: "http://192.168.4.12/onvif/device_service"))
            
            XCTAssertEqual(capabilities.deviceCapabilities.networkCapabilities.owner, testTarget)
            XCTAssertTrue(capabilities.deviceCapabilities.networkCapabilities.isIPFilter)
            XCTAssertTrue(capabilities.deviceCapabilities.networkCapabilities.isZeroConfiguration)
            XCTAssertTrue(capabilities.deviceCapabilities.networkCapabilities.isIPVersion6)
            XCTAssertTrue(capabilities.deviceCapabilities.networkCapabilities.isDynDNS)
            XCTAssertFalse(capabilities.deviceCapabilities.networkCapabilities.isDot11Configuration)
            XCTAssertFalse(capabilities.deviceCapabilities.networkCapabilities.isHostnameFromDHCP)
            XCTAssertFalse(capabilities.deviceCapabilities.networkCapabilities.isDHCPv6)
            XCTAssertNil(capabilities.deviceCapabilities.networkCapabilities.ntp)
            XCTAssertNil(capabilities.deviceCapabilities.networkCapabilities.dot1XConfiguration)
            
            XCTAssertEqual(capabilities.deviceCapabilities.systemCapabilities.owner, testTarget)
            XCTAssertTrue(capabilities.deviceCapabilities.systemCapabilities.isDiscoveryResolve)
            XCTAssertTrue(capabilities.deviceCapabilities.systemCapabilities.isDiscoveryBye)
            XCTAssertTrue(capabilities.deviceCapabilities.systemCapabilities.isSystemLogging)
            XCTAssertFalse(capabilities.deviceCapabilities.systemCapabilities.isRemoteDiscovery)
            XCTAssertFalse(capabilities.deviceCapabilities.systemCapabilities.isSystemBackup)
            XCTAssertFalse(capabilities.deviceCapabilities.systemCapabilities.isFirmwareUpgrade)
            XCTAssertFalse(capabilities.deviceCapabilities.systemCapabilities.isHttpFirmwareUpgrade)
            XCTAssertFalse(capabilities.deviceCapabilities.systemCapabilities.isHttpSystemBackup)
            XCTAssertFalse(capabilities.deviceCapabilities.systemCapabilities.isHttpSystemLogging)
            XCTAssertFalse(capabilities.deviceCapabilities.systemCapabilities.isHttpSupportInformation)
            XCTAssertFalse(capabilities.deviceCapabilities.systemCapabilities.isStorageConfiguration)
            XCTAssertNil(capabilities.deviceCapabilities.systemCapabilities.maxStorageConfigurations)
            XCTAssertNil(capabilities.deviceCapabilities.systemCapabilities.geoLocationEntries)
            XCTAssertNil(capabilities.deviceCapabilities.systemCapabilities.autoGeo)
            XCTAssertNil(capabilities.deviceCapabilities.systemCapabilities.storageTypesSupported)
            
            XCTAssertEqual(capabilities.deviceCapabilities.ioCapabilities.owner, testTarget)
            XCTAssertEqual(capabilities.deviceCapabilities.ioCapabilities.inputConnectors, 4)
            XCTAssertEqual(capabilities.deviceCapabilities.ioCapabilities.relayOutputs, 0)
            XCTAssertNil(capabilities.deviceCapabilities.ioCapabilities.auxiliary)
            
            XCTAssertEqual(capabilities.deviceCapabilities.securityCapabilities.owner, testTarget)
            XCTAssertTrue(capabilities.deviceCapabilities.securityCapabilities.isTLS11)
            XCTAssertTrue(capabilities.deviceCapabilities.securityCapabilities.isTLS12)
            XCTAssertTrue(capabilities.deviceCapabilities.securityCapabilities.isOnboardKeyGeneration)
            XCTAssertTrue(capabilities.deviceCapabilities.securityCapabilities.isAccessPolicyConfig)
            XCTAssertFalse(capabilities.deviceCapabilities.securityCapabilities.isTLS10)
            XCTAssertFalse(capabilities.deviceCapabilities.securityCapabilities.isDefaultAccessPolicy)
            XCTAssertFalse(capabilities.deviceCapabilities.securityCapabilities.isDot1X)
            XCTAssertFalse(capabilities.deviceCapabilities.securityCapabilities.isRemoteUserHandling)
            XCTAssertFalse(capabilities.deviceCapabilities.securityCapabilities.isX509Token)
            XCTAssertFalse(capabilities.deviceCapabilities.securityCapabilities.isSAMLToken)
            XCTAssertFalse(capabilities.deviceCapabilities.securityCapabilities.isKerberosToken)
            XCTAssertFalse(capabilities.deviceCapabilities.securityCapabilities.isUsernameToken)
            XCTAssertFalse(capabilities.deviceCapabilities.securityCapabilities.isHttpDigest)
            XCTAssertFalse(capabilities.deviceCapabilities.securityCapabilities.isRELToken)
            XCTAssertNil(capabilities.deviceCapabilities.securityCapabilities.supportedEAPMethods)
            XCTAssertNil(capabilities.deviceCapabilities.securityCapabilities.maxUsers)
            XCTAssertNil(capabilities.deviceCapabilities.securityCapabilities.maxUserNameLength)
            XCTAssertNil(capabilities.deviceCapabilities.securityCapabilities.maxPasswordLength)
            
            XCTAssertEqual(capabilities.eventsCapabilities.owner, testTarget)
            XCTAssertFalse(capabilities.eventsCapabilities.isWSSubscriptionPolicySupport)
            XCTAssertFalse(capabilities.eventsCapabilities.isWSPullPointSupport)
            XCTAssertFalse(capabilities.eventsCapabilities.isWSPausableSubscriptionManagerInterfaceSupport)
            XCTAssertNil(capabilities.eventsCapabilities.xAddr)

            XCTAssertEqual(capabilities.mediaCapabilities.owner, testTarget)
            XCTAssertFalse(capabilities.mediaCapabilities.isRTPMulticast)
            XCTAssertFalse(capabilities.mediaCapabilities.isRTP_TCP)
            XCTAssertFalse(capabilities.mediaCapabilities.isRTP_RTSP_TCP)
            XCTAssertNil(capabilities.mediaCapabilities.xAddr)
            XCTAssertNil(capabilities.mediaCapabilities.maximumNumberOfProfiles)

            XCTAssertNil(capabilities.analyticsCapabilities)
            XCTAssertNil(capabilities.analyticsDeviceCapabilities)
            XCTAssertNil(capabilities.deviceIOCapabilities)
            XCTAssertNil(capabilities.displayCapabilities)
            XCTAssertNil(capabilities.imagingCapabilities)
            XCTAssertNil(capabilities.ptzCapabilities)
            XCTAssertNil(capabilities.receiverCapabilities)
            XCTAssertNil(capabilities.recordingCapabilities)
            XCTAssertNil(capabilities.replayCapabilities)
            XCTAssertNil(capabilities.searchCapabilities)
        }
    }
    
    /* ############################################################################################################################## */
    // MARK: - Test Methods
    /* ############################################################################################################################## */
    /* ################################################################## */
    /**
     Just setting up our basic structure.
     */
    override func setUp() {
        mockDevice = AxisM5525ECameraMock()
        expectation = XCTestExpectation()
    }
    
    /* ################################################################## */
    /**
     Tests simple initialization (actually, not so simple).
     
     This is a "brute-force" test to make sure that the read-in responses result in an objct that is properly set up.
     */
    func testInitializers() {
        testTarget = RVS_ONVIF_TestTarget(mock: mockDevice, delegate: self)
        wait(for: [expectation], timeout: 10)
        expectation = nil
    }
}
