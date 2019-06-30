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
 Runs tests on a mock Hikvision camera.
 */
class RVS_ONVIF_Tests_HikvisionDS2CD2143G0I_Initializer: RVS_ONVIF_Generic_TestBaseClass {
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
            XCTAssertEqual(deviceInformation["Manufacturer"] as? String, "HIKVISION")
            XCTAssertEqual(deviceInformation["Model"] as? String, "DS-2CD2143G0-I")
            XCTAssertEqual(deviceInformation["FirmwareVersion"] as? String, "V5.5.61 build 180718")
            XCTAssertEqual(deviceInformation["HardwareId"] as? String, "88")
            XCTAssertEqual(deviceInformation["SerialNumber"] as? String, "DS-2CD2143G0-I20180829AAWRC46851082")
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
            XCTAssertEqual(10, services.count)
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
                        XCTAssertEqual(URL(string: "http://192.168.4.13/onvif/device_service"), serviceXAddr)
                    case "http://www.onvif.org/ver10/media/wsdl":
                        XCTAssertEqual(URL(string: "http://192.168.4.13/onvif/Media"), serviceXAddr)
                    case "http://www.onvif.org/ver20/imaging/wsdl":
                        XCTAssertEqual(URL(string: "http://192.168.4.13/onvif/Imaging"), serviceXAddr)
                    case "http://www.onvif.org/ver10/deviceIO/wsdl":
                        XCTAssertEqual(URL(string: "http://192.168.4.13/onvif/DeviceIO"), serviceXAddr)
                    case "http://www.onvif.org/ver20/analytics/wsdl":
                        XCTAssertEqual(URL(string: "http://192.168.4.13/onvif/Analytics"), serviceXAddr)
                    case "http://www.onvif.org/ver10/recording/wsdl":
                        XCTAssertEqual(URL(string: "http://192.168.4.13/onvif/Recording"), serviceXAddr)
                    case "http://www.onvif.org/ver10/search/wsdl":
                        XCTAssertEqual(URL(string: "http://192.168.4.13/onvif/SearchRecording"), serviceXAddr)
                    case "http://www.onvif.org/ver10/replay/wsdl":
                        XCTAssertEqual(URL(string: "http://192.168.4.13/onvif/Replay"), serviceXAddr)
                    case "http://www.onvif.org/ver20/media/wsdl":
                        XCTAssertEqual(URL(string: "http://192.168.4.13/onvif/Media2"), serviceXAddr)
                    case "http://www.onvif.org/ver10/events/wsdl":
                        XCTAssertEqual(URL(string: "http://192.168.4.13/onvif/Events"), serviceXAddr)
                    default:
                        XCTFail("Unknown Service")
                    }
                } else {
                    XCTFail("Service XAddr Missing")
                }
                
                if let version = value.version {
                    switch key {
                    case "http://www.onvif.org/ver10/device/wsdl":
                        XCTAssertEqual("16.12", version)
                    case "http://www.onvif.org/ver10/media/wsdl":
                        XCTAssertEqual("2.60", version)
                    case "http://www.onvif.org/ver20/imaging/wsdl":
                        XCTAssertEqual("16.06", version)
                    case "http://www.onvif.org/ver10/deviceIO/wsdl":
                        XCTAssertEqual("16.12", version)
                    case "http://www.onvif.org/ver20/analytics/wsdl":
                        XCTAssertEqual("16.12", version)
                    case "http://www.onvif.org/ver10/recording/wsdl":
                        XCTAssertEqual("16.12", version)
                    case "http://www.onvif.org/ver10/search/wsdl":
                        XCTAssertEqual("2.42", version)
                    case "http://www.onvif.org/ver10/replay/wsdl":
                        XCTAssertEqual("2.21", version)
                    case "http://www.onvif.org/ver20/media/wsdl":
                        XCTAssertEqual("16.12", version)
                    case "http://www.onvif.org/ver10/events/wsdl":
                        XCTAssertEqual("2.60", version)
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
                XCTAssertTrue(networkCapabilities.isDHCPv6)
                XCTAssertTrue(networkCapabilities.isDynDNS)
                XCTAssertTrue(networkCapabilities.isIPVersion6)
                XCTAssertTrue(networkCapabilities.isHostnameFromDHCP)
                XCTAssertFalse(networkCapabilities.isDot11Configuration)
            } else {
                XCTFail("Service Network Capabilities Record Missing")
            }
            
            if let securityCapabilities = serviceCapabilities.securityCapabilities {
                XCTAssertEqual(securityCapabilities.owner, testTarget)
                XCTAssertEqual(16, securityCapabilities.maxPasswordLength)
                XCTAssertEqual(32, securityCapabilities.maxUserNameLength)
                XCTAssertEqual(32, securityCapabilities.maxUsers)
                XCTAssertEqual([0], securityCapabilities.supportedEAPMethods)
                XCTAssertTrue(securityCapabilities.isTLS10)
                XCTAssertTrue(securityCapabilities.isTLS11)
                XCTAssertTrue(securityCapabilities.isTLS12)
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
                XCTAssertFalse(securityCapabilities.isRELToken)
            } else {
                XCTFail("Service Security Capabilities Record Missing")
            }
            
            if let systemCapabilities = serviceCapabilities.systemCapabilities {
                XCTAssertEqual(systemCapabilities.owner, testTarget)
                XCTAssertEqual(8, systemCapabilities.maxStorageConfigurations)
                XCTAssertTrue(systemCapabilities.isDiscoveryBye)
                XCTAssertTrue(systemCapabilities.isFirmwareUpgrade)
                XCTAssertTrue(systemCapabilities.isSystemLogging)
                XCTAssertTrue(systemCapabilities.isHttpFirmwareUpgrade)
                XCTAssertTrue(systemCapabilities.isStorageConfiguration)
                XCTAssertFalse(systemCapabilities.isHttpSupportInformation)
                XCTAssertFalse(systemCapabilities.isHttpSystemLogging)
                XCTAssertFalse(systemCapabilities.isSystemBackup)
                XCTAssertFalse(systemCapabilities.isDiscoveryResolve)
                XCTAssertFalse(systemCapabilities.isHttpSystemBackup)
                XCTAssertFalse(systemCapabilities.isRemoteDiscovery)
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
                    XCTAssertEqual("city/hangzhou", location)
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
                    XCTAssertEqual("DS-2CD2143G0-I", hardware)
                    XCTAssertFalse(scope.isConfigurable)
                } else if case let RVS_ONVIF_Core.Scope.Category.Name(name) = scope.category {
                    XCTAssertEqual("HIKVISION DS-2CD2143G0-I", name)
                    XCTAssertTrue(scope.isConfigurable)
                } else if case let RVS_ONVIF_Core.Scope.Category.Custom(name, value) = scope.category, name == "Mac", value == "58:03:fb:8a:57:9b" {
                    XCTAssertFalse(scope.isConfigurable)
                } else if case let RVS_ONVIF_Core.Scope.Category.Custom(name, value) = scope.category, name == "Type", value == "video_encoder" {
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
                XCTAssertEqual(networkInterface.info.hwAddress, "58:03:fb:8a:57:9b")
                XCTAssertEqual(networkInterface.info.mtu, 1500)
                
                XCTAssertEqual(networkInterface.link.interfaceType, .other)
                
                XCTAssertEqual(networkInterface.link.adminSettings.owner, testTarget)
                XCTAssertTrue(networkInterface.link.adminSettings.autoNegotiation)
                XCTAssertEqual(networkInterface.link.adminSettings.speed, 100)
                XCTAssertEqual(networkInterface.link.adminSettings.duplex, .Full)
                
                XCTAssertEqual(networkInterface.link.operSettings.owner, testTarget)
                XCTAssertTrue(networkInterface.link.operSettings.autoNegotiation)
                XCTAssertEqual(networkInterface.link.operSettings.speed, 100)
                XCTAssertEqual(networkInterface.link.operSettings.duplex, .Full)
                
                XCTAssertTrue(networkInterface.ipV4.isEnabled)
                XCTAssertFalse(networkInterface.ipV4.configuration.isDHCP)
                XCTAssertEqual(1, networkInterface.ipV4.configuration.manual.count)
                XCTAssertEqual(24, networkInterface.ipV4.configuration.manual[0].prefixLength)
                XCTAssertEqual("192.168.4.13", networkInterface.ipV4.configuration.manual[0].address.address)
                XCTAssertNil(networkInterface.ipV4.configuration.linkLocal)
                XCTAssertNil(networkInterface.ipV4.configuration.fromDHCP)
                XCTAssertNil(networkInterface.ipV4.configuration.fromRA)
                XCTAssertNil(networkInterface.ipV4.configuration.isAbleToAcceptRouterAdvert)
                XCTAssertNil(networkInterface.ipV4.configuration.ipv6ConfigurationExtension)
                
                XCTAssertTrue(networkInterface.ipV6.isEnabled)
                XCTAssertFalse(networkInterface.ipV6.configuration.isDHCP)
                XCTAssertNil(networkInterface.ipV6.configuration.manual)
                XCTAssertEqual(1, networkInterface.ipV6.configuration.linkLocal.count)
                XCTAssertEqual(64, networkInterface.ipV6.configuration.linkLocal[0].prefixLength)
                XCTAssertEqual("fe80::5a03:fbff:fe8a:579b", networkInterface.ipV6.configuration.linkLocal[0].address.address)
                XCTAssertEqual(1, networkInterface.ipV6.configuration.fromDHCP.count)
                XCTAssertEqual(64, networkInterface.ipV6.configuration.fromDHCP[0].prefixLength)
                XCTAssertEqual("fe80::5a03:fbff:fe8a:579b", networkInterface.ipV6.configuration.fromDHCP[0].address.address)
                XCTAssertEqual(1, networkInterface.ipV6.configuration.fromRA.count)
                XCTAssertEqual(64, networkInterface.ipV6.configuration.fromRA[0].prefixLength)
                XCTAssertEqual("fc00::5a03:fbff:fe8a:579b", networkInterface.ipV6.configuration.fromRA[0].address.address)
                XCTAssertFalse(networkInterface.ipV6.configuration.isAbleToAcceptRouterAdvert)
                XCTAssertNil(networkInterface.ipV6.configuration.ipv6ConfigurationExtension)
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
            
            XCTAssertEqual(capabilities.analyticsCapabilities.owner, testTarget)
            XCTAssertEqual(capabilities.analyticsCapabilities.xAddr, URL(string: "http://192.168.4.13/onvif/Analytics"))
            XCTAssertTrue(capabilities.analyticsCapabilities.isRuleSupport)
            XCTAssertTrue(capabilities.analyticsCapabilities.isAnalyticsModuleSupport)

            XCTAssertEqual(capabilities.deviceCapabilities.owner, testTarget)
            XCTAssertEqual(capabilities.deviceCapabilities.xAddr, URL(string: "http://192.168.4.13/onvif/device_service"))
            
            XCTAssertEqual(capabilities.deviceCapabilities.networkCapabilities.owner, testTarget)
            XCTAssertTrue(capabilities.deviceCapabilities.networkCapabilities.isIPFilter)
            XCTAssertTrue(capabilities.deviceCapabilities.networkCapabilities.isZeroConfiguration)
            XCTAssertTrue(capabilities.deviceCapabilities.networkCapabilities.isIPVersion6)
            XCTAssertTrue(capabilities.deviceCapabilities.networkCapabilities.isDynDNS)
            XCTAssertFalse(capabilities.deviceCapabilities.networkCapabilities.isHostnameFromDHCP)
            XCTAssertFalse(capabilities.deviceCapabilities.networkCapabilities.isDot11Configuration)
            XCTAssertFalse(capabilities.deviceCapabilities.networkCapabilities.isDHCPv6)
            XCTAssertNil(capabilities.deviceCapabilities.networkCapabilities.dot1XConfiguration)
            XCTAssertNil(capabilities.deviceCapabilities.networkCapabilities.ntp)
            
            XCTAssertEqual(capabilities.deviceCapabilities.systemCapabilities.owner, testTarget)
            XCTAssertFalse(capabilities.deviceCapabilities.systemCapabilities.isDiscoveryResolve)
            XCTAssertTrue(capabilities.deviceCapabilities.systemCapabilities.isDiscoveryBye)
            XCTAssertFalse(capabilities.deviceCapabilities.systemCapabilities.isRemoteDiscovery)
            XCTAssertFalse(capabilities.deviceCapabilities.systemCapabilities.isSystemBackup)
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
            XCTAssertEqual(capabilities.deviceCapabilities.ioCapabilities.inputConnectors, 0)
            XCTAssertEqual(capabilities.deviceCapabilities.ioCapabilities.relayOutputs, 0)
            XCTAssertNil(capabilities.deviceCapabilities.ioCapabilities.auxiliary)
            
            XCTAssertEqual(capabilities.deviceCapabilities.securityCapabilities.owner, testTarget)
            XCTAssertFalse(capabilities.deviceCapabilities.securityCapabilities.isTLS10)
            XCTAssertTrue(capabilities.deviceCapabilities.securityCapabilities.isTLS11)
            XCTAssertTrue(capabilities.deviceCapabilities.securityCapabilities.isTLS12)
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
        mockDevice = HikvisionDS2CD2143G0IMock()
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
