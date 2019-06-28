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
                if case let RVS_ONVIF_MacOS_Tests.RVS_ONVIF_Core.Scope.Category.Location(location) = scope.category {
                    XCTAssertEqual("", location)
                    XCTAssertTrue(scope.isConfigurable)
                } else if case let RVS_ONVIF_MacOS_Tests.RVS_ONVIF_Core.Scope.Category.Profile(profile) = scope.category {
                    switch profile {
                    case let .S(alt):
                        XCTAssertEqual("Streaming", alt)
                    case let .G(alt):
                        XCTAssertEqual("G", alt)
                    default:
                        XCTFail("Unknown Profile")
                    }
                    XCTAssertFalse(scope.isConfigurable)
                } else if case let RVS_ONVIF_MacOS_Tests.RVS_ONVIF_Core.Scope.Category.Hardware(hardware) = scope.category {
                    XCTAssertEqual("M5525-E", hardware)
                    XCTAssertFalse(scope.isConfigurable)
                } else if case let RVS_ONVIF_MacOS_Tests.RVS_ONVIF_Core.Scope.Category.Name(name) = scope.category {
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
            }
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
     */
    func testInitializers() {
        testTarget = RVS_ONVIF_TestTarget(mock: mockDevice, delegate: self)
        wait(for: [expectation], timeout: 10)
        expectation = nil
    }
}
