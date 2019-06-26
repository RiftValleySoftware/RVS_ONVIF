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
 This is a base class, used for specific tests. It implements a RVS_ONVIF-derived test class instance, and logs in with a fictitous ID and IP Address/port.
 This conforms to the RVS_ONVIFDelegate protocol, and registers as the instance delegate, so derived classes can use that.
 It will not work on-device, as this has a nil SOAPEngine key.
 You can change the IP Address/Port and login ID prior to calling this class instance's setup() method.
 */
class RVS_ONVIF_iOS_TestBaseClass: XCTestCase, RVS_ONVIFDelegate {
    /* ################################################################## */
    /**
     Set up prior to every test.
     */
    override func setUp() {
    }
    
    func testSimple() {
        let axisCamera = AxisCameraMock()
        
        print(axisCamera.makeTransaction(["action": "trt:GetDeviceInformation"]) ?? "ERROR")
        
        let testTarget = RVS_ONVIF_TestTarget(mock: axisCamera, delegate: self)
        let expectation = XCTestExpectation()
        
        print(String(reflecting: testTarget))
        
        // Wait until the expectation is fulfilled, with a timeout of half a second.
        wait(for: [expectation], timeout: 10)
        
        print(String(reflecting: testTarget))
    }
}

class AxisCameraMock: RVS_ONVIF_TestTarget_MockDevice {
    override var lookupTable: [String: String] {
        get {
            return [
                "trt:GetDeviceInformation": "<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:SOAP-ENC=\"http://www.w3.org/2003/05/soap-encoding\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:c14n=\"http://www.w3.org/2001/10/xml-exc-c14n#\" xmlns:wsu=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd\" xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\" xmlns:wsse=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd\" xmlns:wsa5=\"http://www.w3.org/2005/08/addressing\" xmlns:xmime=\"http://tempuri.org/xmime.xsd\" xmlns:xop=\"http://www.w3.org/2004/08/xop/include\" xmlns:wsrfbf=\"http://docs.oasis-open.org/wsrf/bf-2\" xmlns:wstop=\"http://docs.oasis-open.org/wsn/t-1\" xmlns:tt=\"http://www.onvif.org/ver10/schema\" xmlns:acert=\"http://www.axis.com/vapix/ws/cert\" xmlns:wsrfr=\"http://docs.oasis-open.org/wsrf/r-2\" xmlns:aa=\"http://www.axis.com/vapix/ws/action1\" xmlns:acertificates=\"http://www.axis.com/vapix/ws/certificates\" xmlns:aentry=\"http://www.axis.com/vapix/ws/entry\" xmlns:aev=\"http://www.axis.com/vapix/ws/event1\" xmlns:aeva=\"http://www.axis.com/vapix/ws/embeddedvideoanalytics1\" xmlns:ali1=\"http://www.axis.com/vapix/ws/light/CommonBinding\" xmlns:ali2=\"http://www.axis.com/vapix/ws/light/IntensityBinding\" xmlns:ali3=\"http://www.axis.com/vapix/ws/light/AngleOfIlluminationBinding\" xmlns:ali4=\"http://www.axis.com/vapix/ws/light/DayNightSynchronizeBinding\" xmlns:ali=\"http://www.axis.com/vapix/ws/light\" xmlns:apc=\"http://www.axis.com/vapix/ws/panopsiscalibration1\" xmlns:arth=\"http://www.axis.com/vapix/ws/recordedtour1\" xmlns:asd=\"http://www.axis.com/vapix/ws/shockdetection\" xmlns:aweb=\"http://www.axis.com/vapix/ws/webserver\" xmlns:tan1=\"http://www.onvif.org/ver20/analytics/wsdl/RuleEngineBinding\" xmlns:tan2=\"http://www.onvif.org/ver20/analytics/wsdl/AnalyticsEngineBinding\" xmlns:tan=\"http://www.onvif.org/ver20/analytics/wsdl\" xmlns:tds=\"http://www.onvif.org/ver10/device/wsdl\" xmlns:tev1=\"http://www.onvif.org/ver10/events/wsdl/NotificationProducerBinding\" xmlns:tev2=\"http://www.onvif.org/ver10/events/wsdl/EventBinding\" xmlns:tev3=\"http://www.onvif.org/ver10/events/wsdl/SubscriptionManagerBinding\" xmlns:wsnt=\"http://docs.oasis-open.org/wsn/b-2\" xmlns:tev4=\"http://www.onvif.org/ver10/events/wsdl/PullPointSubscriptionBinding\" xmlns:tev=\"http://www.onvif.org/ver10/events/wsdl\" xmlns:timg=\"http://www.onvif.org/ver20/imaging/wsdl\" xmlns:tmd=\"http://www.onvif.org/ver10/deviceIO/wsdl\" xmlns:tptz=\"http://www.onvif.org/ver20/ptz/wsdl\" xmlns:trc=\"http://www.onvif.org/ver10/recording/wsdl\" xmlns:trp=\"http://www.onvif.org/ver10/replay/wsdl\" xmlns:trt=\"http://www.onvif.org/ver10/media/wsdl\" xmlns:tse=\"http://www.onvif.org/ver10/search/wsdl\" xmlns:ter=\"http://www.onvif.org/ver10/error\" xmlns:tns1=\"http://www.onvif.org/ver10/topics\" xmlns:tnsaxis=\"http://www.axis.com/2009/event/topics\"><SOAP-ENV:Body><tds:GetDeviceInformationResponse><tds:Manufacturer>AXIS</tds:Manufacturer><tds:Model>M5525-E</tds:Model><tds:FirmwareVersion>8.40.1.1</tds:FirmwareVersion><tds:SerialNumber>ACCC8EBECCEA</tds:SerialNumber><tds:HardwareId>757</tds:HardwareId></tds:GetDeviceInformationResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>"
            ]
        }
        
        set {
            
        }
    }
}
