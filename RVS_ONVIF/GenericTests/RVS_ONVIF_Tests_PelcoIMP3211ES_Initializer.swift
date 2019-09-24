/** 
 © Copyright 2019, The Great Rift Valley Software Company

LICENSE:

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

The Great Rift Valley Software Company: https://riftvalleysoftware.com
*/

import XCTest

/* ###################################################################################################################################### */
/**
 Runs tests on a mock Pelco camera.
 */
class RVS_ONVIF_Tests_PelcoIMP3211ES_Initializer: RVS_ONVIF_Generic_TestBaseClass {
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
        if let deviceInformation = testTarget.deviceInformation {
            XCTAssertEqual(5, deviceInformation.count)
            XCTAssertEqual(deviceInformation["Manufacturer"] as? String, "pelco")
            XCTAssertEqual(deviceInformation["Model"] as? String, "IMP321-1ES")
            XCTAssertEqual(deviceInformation["FirmwareVersion"] as? String, "01.16.42-20180912")
            XCTAssertEqual(deviceInformation["SerialNumber"] as? String, "T82212128")
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
            XCTAssertEqual(8, services.count)
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
                    case "http://www.onvif.org/ver20/imaging/wsdl":
                        XCTAssertEqual(URL(string: "http://192.168.4.18:80/onvif/device_service"), serviceXAddr)
                    case "http://www.onvif.org/ver10/media/wsdl":
                        XCTAssertEqual(URL(string: "http://192.168.4.18:80/onvif/device_service"), serviceXAddr)
                    case "http://www.onvif.org/ver10/device/wsdl":
                        XCTAssertEqual(URL(string: "http://192.168.4.18:80/onvif/device_service"), serviceXAddr)
                    case "http://www.onvif.org/ver10/deviceIO/wsdl":
                        XCTAssertEqual(URL(string: "http://192.168.4.18:80/onvif/device_service"), serviceXAddr)
                    case "http://www.onvif.org/ver10/events/wsdl":
                        XCTAssertEqual(URL(string: "http://192.168.4.18:80/onvif/subscribe_service"), serviceXAddr)
                    case "http://www.onvif.org/ver10/recording/wsdl":
                        XCTAssertEqual(URL(string: "http://192.168.4.18:80/onvif/device_service"), serviceXAddr)
                    case "http://www.onvif.org/ver10/search/wsdl":
                        XCTAssertEqual(URL(string: "http://192.168.4.18:80/onvif/device_service"), serviceXAddr)
                    case "http://www.onvif.org/ver10/replay/wsdl":
                        XCTAssertEqual(URL(string: "http://192.168.4.18:80/onvif/device_service"), serviceXAddr)
                    default:
                        XCTFail("Unknown Service")
                    }
                } else {
                    XCTFail("Service XAddr Missing")
                }
                
                if let version = value.version {
                    switch key {
                    case "http://www.onvif.org/ver20/imaging/wsdl":
                        XCTAssertEqual("16.06", version)
                    case "http://www.onvif.org/ver10/media/wsdl":
                        XCTAssertEqual("16.06", version)
                    case "http://www.onvif.org/ver10/device/wsdl":
                        XCTAssertEqual("16.06", version)
                    case "http://www.onvif.org/ver10/deviceIO/wsdl":
                        XCTAssertEqual("16.06", version)
                    case "http://www.onvif.org/ver10/events/wsdl":
                        XCTAssertEqual("16.06", version)
                    case "http://www.onvif.org/ver10/recording/wsdl":
                        XCTAssertEqual("2.50", version)
                    case "http://www.onvif.org/ver10/search/wsdl":
                        XCTAssertEqual("16.06", version)
                    case "http://www.onvif.org/ver10/replay/wsdl":
                        XCTAssertEqual("2.21", version)
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
                XCTAssertEqual(1, networkCapabilities.ntp)
                XCTAssertEqual(0, networkCapabilities.dot1XConfiguration)
                XCTAssertTrue(networkCapabilities.isZeroConfiguration)
                XCTAssertTrue(networkCapabilities.isIPFilter)
                XCTAssertFalse(networkCapabilities.isDHCPv6)
                XCTAssertFalse(networkCapabilities.isDynDNS)
                XCTAssertFalse(networkCapabilities.isIPVersion6)
                XCTAssertFalse(networkCapabilities.isHostnameFromDHCP)
                XCTAssertFalse(networkCapabilities.isDot11Configuration)
            } else {
                XCTFail("Service Network Capabilities Record Missing")
            }
            
            if let securityCapabilities = serviceCapabilities.securityCapabilities {
                XCTAssertEqual(securityCapabilities.owner, testTarget)
                XCTAssertEqual(40, securityCapabilities.maxPasswordLength)
                XCTAssertEqual(40, securityCapabilities.maxUserNameLength)
                XCTAssertEqual(10, securityCapabilities.maxUsers)
                XCTAssertTrue(securityCapabilities.isHttpDigest)
                XCTAssertTrue(securityCapabilities.isUsernameToken)
                XCTAssertTrue(securityCapabilities.isDefaultAccessPolicy)
                XCTAssertFalse(securityCapabilities.isSAMLToken)
                XCTAssertFalse(securityCapabilities.isKerberosToken)
                XCTAssertFalse(securityCapabilities.isX509Token)
                XCTAssertFalse(securityCapabilities.isDot1X)
                XCTAssertFalse(securityCapabilities.isRemoteUserHandling)
                XCTAssertFalse(securityCapabilities.isAccessPolicyConfig)
                XCTAssertFalse(securityCapabilities.isOnboardKeyGeneration)
                XCTAssertFalse(securityCapabilities.isTLS10)
                XCTAssertFalse(securityCapabilities.isTLS11)
                XCTAssertFalse(securityCapabilities.isTLS12)
                XCTAssertFalse(securityCapabilities.isRELToken)
                XCTAssertNil(securityCapabilities.supportedEAPMethods)
            } else {
                XCTFail("Service Security Capabilities Record Missing")
            }
            
            if let systemCapabilities = serviceCapabilities.systemCapabilities {
                XCTAssertEqual(systemCapabilities.owner, testTarget)
                XCTAssertTrue(systemCapabilities.isDiscoveryBye)
                XCTAssertTrue(systemCapabilities.isHttpSupportInformation)
                XCTAssertTrue(systemCapabilities.isHttpSystemLogging)
                XCTAssertTrue(systemCapabilities.isFirmwareUpgrade)
                XCTAssertTrue(systemCapabilities.isSystemLogging)
                XCTAssertTrue(systemCapabilities.isSystemBackup)
                XCTAssertTrue(systemCapabilities.isHttpFirmwareUpgrade)
                XCTAssertFalse(systemCapabilities.isDiscoveryResolve)
                XCTAssertFalse(systemCapabilities.isStorageConfiguration)
                XCTAssertFalse(systemCapabilities.isHttpSystemBackup)
                XCTAssertFalse(systemCapabilities.isRemoteDiscovery)
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
                    case let .Q(alt):
                        XCTAssertEqual("Q/Operational", alt)
                    case let .G(alt):
                        XCTAssertEqual("G", alt)
                    default:
                        XCTFail("Unknown Profile")
                    }
                    XCTAssertFalse(scope.isConfigurable)
                } else if case let RVS_ONVIF_Core.Scope.Category.Hardware(hardware) = scope.category {
                    XCTAssertEqual("IMP321-1ES", hardware)
                    XCTAssertFalse(scope.isConfigurable)
                } else if case let RVS_ONVIF_Core.Scope.Category.Name(name) = scope.category {
                    XCTAssertEqual("PelcoCameraSide", name)
                    XCTAssertFalse(scope.isConfigurable)
                } else if case let RVS_ONVIF_Core.Scope.Category.Custom(name, value) = scope.category, name == "Type", value == "basic" {
                    ()
                } else if case let RVS_ONVIF_Core.Scope.Category.Custom(name, value) = scope.category, name == "Type", value == "audio_encoder" {
                    ()
                } else if case let RVS_ONVIF_Core.Scope.Category.Custom(name, value) = scope.category, name == "Type", value == "video_encoder" {
                    ()
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
                XCTAssertEqual(networkInterface.token, "1")
                XCTAssertTrue(networkInterface.isEnabled)
                XCTAssertEqual(networkInterface.info.name, "eth0")
                XCTAssertEqual(networkInterface.info.hwAddress, "00:04:7d:36:a5:4e")
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
            XCTAssertEqual(capabilities.deviceCapabilities.xAddr, URL(string: "http://192.168.4.18:80/onvif/device_service"))
            
            XCTAssertEqual(capabilities.deviceCapabilities.networkCapabilities.owner, testTarget)
            XCTAssertTrue(capabilities.deviceCapabilities.networkCapabilities.isIPFilter)
            XCTAssertTrue(capabilities.deviceCapabilities.networkCapabilities.isZeroConfiguration)
            XCTAssertFalse(capabilities.deviceCapabilities.networkCapabilities.isIPVersion6)
            XCTAssertFalse(capabilities.deviceCapabilities.networkCapabilities.isDynDNS)
            XCTAssertFalse(capabilities.deviceCapabilities.networkCapabilities.isDot11Configuration)
            XCTAssertFalse(capabilities.deviceCapabilities.networkCapabilities.isDHCPv6)
            XCTAssertFalse(capabilities.deviceCapabilities.networkCapabilities.isHostnameFromDHCP)
            XCTAssertNil(capabilities.deviceCapabilities.networkCapabilities.dot1XConfiguration)
            XCTAssertNil(capabilities.deviceCapabilities.networkCapabilities.ntp)
            
            XCTAssertEqual(capabilities.deviceCapabilities.systemCapabilities.owner, testTarget)
            XCTAssertFalse(capabilities.deviceCapabilities.systemCapabilities.isDiscoveryResolve)
            XCTAssertTrue(capabilities.deviceCapabilities.systemCapabilities.isDiscoveryBye)
            XCTAssertFalse(capabilities.deviceCapabilities.systemCapabilities.isRemoteDiscovery)
            XCTAssertTrue(capabilities.deviceCapabilities.systemCapabilities.isSystemBackup)
            XCTAssertTrue(capabilities.deviceCapabilities.systemCapabilities.isSystemLogging)
            XCTAssertTrue(capabilities.deviceCapabilities.systemCapabilities.isFirmwareUpgrade)
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
            XCTAssertEqual(capabilities.deviceCapabilities.ioCapabilities.inputConnectors, 1)
            XCTAssertEqual(capabilities.deviceCapabilities.ioCapabilities.relayOutputs, 1)
            XCTAssertNil(capabilities.deviceCapabilities.ioCapabilities.auxiliary)
            
            XCTAssertEqual(capabilities.deviceCapabilities.securityCapabilities.owner, testTarget)
            XCTAssertFalse(capabilities.deviceCapabilities.securityCapabilities.isTLS10)
            XCTAssertFalse(capabilities.deviceCapabilities.securityCapabilities.isTLS11)
            XCTAssertFalse(capabilities.deviceCapabilities.securityCapabilities.isTLS12)
            XCTAssertFalse(capabilities.deviceCapabilities.securityCapabilities.isOnboardKeyGeneration)
            XCTAssertFalse(capabilities.deviceCapabilities.securityCapabilities.isAccessPolicyConfig)
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
            XCTAssertTrue(capabilities.eventsCapabilities.isWSSubscriptionPolicySupport)
            XCTAssertTrue(capabilities.eventsCapabilities.isWSPullPointSupport)
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
        mockDevice = PelcoIMP3211ESCameraMock()
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
