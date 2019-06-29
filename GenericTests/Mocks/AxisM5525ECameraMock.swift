/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

/* ###################################################################################################################################### */
/**
 This mocks an AXIS M5525-E PTZ camera.
 */
class AxisM5525ECameraMock: RVS_ONVIF_TestTarget_MockDevice {
    /* ################################################################## */
    /**
     This is a name for the mock device.
     */
    override var name: String {
        return "AXIS M5525-E"
    }
    
    /* ################################################################## */
    /**
     These are the mock command responses.
     */
    override var lookupTable: [String: String] {
        get {
            return [
                /// Core GetDeviceInformation
                "trt:GetDeviceInformation":
                "<SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:SOAP-ENC=\"http://www.w3.org/2003/05/soap-encoding\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:c14n=\"http://www.w3.org/2001/10/xml-exc-c14n#\" xmlns:wsu=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd\" xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\" xmlns:wsse=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd\" xmlns:wsa5=\"http://www.w3.org/2005/08/addressing\" xmlns:xmime=\"http://tempuri.org/xmime.xsd\" xmlns:xop=\"http://www.w3.org/2004/08/xop/include\" xmlns:wsrfbf=\"http://docs.oasis-open.org/wsrf/bf-2\" xmlns:wstop=\"http://docs.oasis-open.org/wsn/t-1\" xmlns:tt=\"http://www.onvif.org/ver10/schema\" xmlns:acert=\"http://www.axis.com/vapix/ws/cert\" xmlns:wsrfr=\"http://docs.oasis-open.org/wsrf/r-2\" xmlns:aa=\"http://www.axis.com/vapix/ws/action1\" xmlns:acertificates=\"http://www.axis.com/vapix/ws/certificates\" xmlns:aentry=\"http://www.axis.com/vapix/ws/entry\" xmlns:aev=\"http://www.axis.com/vapix/ws/event1\" xmlns:aeva=\"http://www.axis.com/vapix/ws/embeddedvideoanalytics1\" xmlns:ali1=\"http://www.axis.com/vapix/ws/light/CommonBinding\" xmlns:ali2=\"http://www.axis.com/vapix/ws/light/IntensityBinding\" xmlns:ali3=\"http://www.axis.com/vapix/ws/light/AngleOfIlluminationBinding\" xmlns:ali4=\"http://www.axis.com/vapix/ws/light/DayNightSynchronizeBinding\" xmlns:ali=\"http://www.axis.com/vapix/ws/light\" xmlns:apc=\"http://www.axis.com/vapix/ws/panopsiscalibration1\" xmlns:arth=\"http://www.axis.com/vapix/ws/recordedtour1\" xmlns:asd=\"http://www.axis.com/vapix/ws/shockdetection\" xmlns:aweb=\"http://www.axis.com/vapix/ws/webserver\" xmlns:tan1=\"http://www.onvif.org/ver20/analytics/wsdl/RuleEngineBinding\" xmlns:tan2=\"http://www.onvif.org/ver20/analytics/wsdl/AnalyticsEngineBinding\" xmlns:tan=\"http://www.onvif.org/ver20/analytics/wsdl\" xmlns:tds=\"http://www.onvif.org/ver10/device/wsdl\" xmlns:tev1=\"http://www.onvif.org/ver10/events/wsdl/NotificationProducerBinding\" xmlns:tev2=\"http://www.onvif.org/ver10/events/wsdl/EventBinding\" xmlns:tev3=\"http://www.onvif.org/ver10/events/wsdl/SubscriptionManagerBinding\" xmlns:wsnt=\"http://docs.oasis-open.org/wsn/b-2\" xmlns:tev4=\"http://www.onvif.org/ver10/events/wsdl/PullPointSubscriptionBinding\" xmlns:tev=\"http://www.onvif.org/ver10/events/wsdl\" xmlns:timg=\"http://www.onvif.org/ver20/imaging/wsdl\" xmlns:tmd=\"http://www.onvif.org/ver10/deviceIO/wsdl\" xmlns:tptz=\"http://www.onvif.org/ver20/ptz/wsdl\" xmlns:trc=\"http://www.onvif.org/ver10/recording/wsdl\" xmlns:trp=\"http://www.onvif.org/ver10/replay/wsdl\" xmlns:trt=\"http://www.onvif.org/ver10/media/wsdl\" xmlns:tse=\"http://www.onvif.org/ver10/search/wsdl\" xmlns:ter=\"http://www.onvif.org/ver10/error\" xmlns:tns1=\"http://www.onvif.org/ver10/topics\" xmlns:tnsaxis=\"http://www.axis.com/2009/event/topics\"><SOAP-ENV:Body><tds:GetDeviceInformationResponse><tds:Manufacturer>AXIS</tds:Manufacturer><tds:Model>M5525-E</tds:Model><tds:FirmwareVersion>8.40.1.1</tds:FirmwareVersion><tds:SerialNumber>ACCC8EBECCEA</tds:SerialNumber><tds:HardwareId>757</tds:HardwareId></tds:GetDeviceInformationResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>",

                /// Core GetServices
                "trt:GetServicestrue":
                "<?xml version=\"1.0\" encoding=\"UTF-8\"?> <SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:SOAP-ENC=\"http://www.w3.org/2003/05/soap-encoding\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:c14n=\"http://www.w3.org/2001/10/xml-exc-c14n#\" xmlns:wsu=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd\" xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\" xmlns:wsse=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd\" xmlns:wsa5=\"http://www.w3.org/2005/08/addressing\" xmlns:xmime=\"http://tempuri.org/xmime.xsd\" xmlns:xop=\"http://www.w3.org/2004/08/xop/include\" xmlns:wsrfbf=\"http://docs.oasis-open.org/wsrf/bf-2\" xmlns:wstop=\"http://docs.oasis-open.org/wsn/t-1\" xmlns:tt=\"http://www.onvif.org/ver10/schema\" xmlns:acert=\"http://www.axis.com/vapix/ws/cert\" xmlns:wsrfr=\"http://docs.oasis-open.org/wsrf/r-2\" xmlns:aa=\"http://www.axis.com/vapix/ws/action1\" xmlns:acertificates=\"http://www.axis.com/vapix/ws/certificates\" xmlns:aentry=\"http://www.axis.com/vapix/ws/entry\" xmlns:aev=\"http://www.axis.com/vapix/ws/event1\" xmlns:aeva=\"http://www.axis.com/vapix/ws/embeddedvideoanalytics1\" xmlns:ali1=\"http://www.axis.com/vapix/ws/light/CommonBinding\" xmlns:ali2=\"http://www.axis.com/vapix/ws/light/IntensityBinding\" xmlns:ali3=\"http://www.axis.com/vapix/ws/light/AngleOfIlluminationBinding\" xmlns:ali4=\"http://www.axis.com/vapix/ws/light/DayNightSynchronizeBinding\" xmlns:ali=\"http://www.axis.com/vapix/ws/light\" xmlns:apc=\"http://www.axis.com/vapix/ws/panopsiscalibration1\" xmlns:arth=\"http://www.axis.com/vapix/ws/recordedtour1\" xmlns:asd=\"http://www.axis.com/vapix/ws/shockdetection\" xmlns:aweb=\"http://www.axis.com/vapix/ws/webserver\" xmlns:tan1=\"http://www.onvif.org/ver20/analytics/wsdl/RuleEngineBinding\" xmlns:tan2=\"http://www.onvif.org/ver20/analytics/wsdl/AnalyticsEngineBinding\" xmlns:tan=\"http://www.onvif.org/ver20/analytics/wsdl\" xmlns:tds=\"http://www.onvif.org/ver10/device/wsdl\" xmlns:tev1=\"http://www.onvif.org/ver10/events/wsdl/NotificationProducerBinding\" xmlns:tev2=\"http://www.onvif.org/ver10/events/wsdl/EventBinding\" xmlns:tev3=\"http://www.onvif.org/ver10/events/wsdl/SubscriptionManagerBinding\" xmlns:wsnt=\"http://docs.oasis-open.org/wsn/b-2\" xmlns:tev4=\"http://www.onvif.org/ver10/events/wsdl/PullPointSubscriptionBinding\" xmlns:tev=\"http://www.onvif.org/ver10/events/wsdl\" xmlns:timg=\"http://www.onvif.org/ver20/imaging/wsdl\" xmlns:tmd=\"http://www.onvif.org/ver10/deviceIO/wsdl\" xmlns:tptz=\"http://www.onvif.org/ver20/ptz/wsdl\" xmlns:trc=\"http://www.onvif.org/ver10/recording/wsdl\" xmlns:trp=\"http://www.onvif.org/ver10/replay/wsdl\" xmlns:trt=\"http://www.onvif.org/ver10/media/wsdl\" xmlns:tse=\"http://www.onvif.org/ver10/search/wsdl\" xmlns:ter=\"http://www.onvif.org/ver10/error\" xmlns:tns1=\"http://www.onvif.org/ver10/topics\" xmlns:tnsaxis=\"http://www.axis.com/2009/event/topics\"><SOAP-ENV:Header></SOAP-ENV:Header><SOAP-ENV:Body><tds:GetServicesResponse><tds:Service><tds:Namespace>http://www.onvif.org/ver20/ptz/wsdl</tds:Namespace><tds:XAddr>http://192.168.4.12/onvif/services</tds:XAddr><tds:Capabilities> <tptz:Capabilities xmlns:tptz=\"http://www.onvif.org/ver20/ptz/wsdl\"></tptz:Capabilities></tds:Capabilities><tds:Version><tt:Major>2</tt:Major><tt:Minor>41</tt:Minor></tds:Version></tds:Service><tds:Service><tds:Namespace>http://www.onvif.org/ver10/events/wsdl</tds:Namespace><tds:XAddr>http://192.168.4.12/onvif/services</tds:XAddr><tds:Capabilities> <tev:Capabilities xmlns:tev=\"http://www.onvif.org/ver10/events/wsdl\" MaxPullPoints=\"4\" MaxNotificationProducers=\"4\"></tev:Capabilities></tds:Capabilities><tds:Version><tt:Major>2</tt:Major><tt:Minor>21</tt:Minor></tds:Version></tds:Service><tds:Service><tds:Namespace>http://www.axis.com/vapix/ws/action1</tds:Namespace><tds:XAddr>http://192.168.4.12/onvif/services</tds:XAddr><tds:Version><tt:Major>1</tt:Major><tt:Minor>1</tt:Minor></tds:Version></tds:Service><tds:Service><tds:Namespace>http://www.axis.com/vapix/ws/certificates</tds:Namespace><tds:XAddr>http://192.168.4.12/onvif/services</tds:XAddr><tds:Version><tt:Major>1</tt:Major><tt:Minor>1</tt:Minor></tds:Version></tds:Service><tds:Service><tds:Namespace>http://www.axis.com/vapix/ws/entry</tds:Namespace><tds:XAddr>http://192.168.4.12/onvif/services</tds:XAddr><tds:Version><tt:Major>1</tt:Major><tt:Minor>1</tt:Minor></tds:Version></tds:Service><tds:Service><tds:Namespace>http://www.axis.com/vapix/ws/event1</tds:Namespace><tds:XAddr>http://192.168.4.12/onvif/services</tds:XAddr><tds:Version><tt:Major>1</tt:Major><tt:Minor>1</tt:Minor></tds:Version></tds:Service><tds:Service><tds:Namespace>http://www.axis.com/vapix/ws/webserver</tds:Namespace><tds:XAddr>http://192.168.4.12/onvif/services</tds:XAddr><tds:Version><tt:Major>1</tt:Major><tt:Minor>1</tt:Minor></tds:Version></tds:Service><tds:Service><tds:Namespace>http://www.onvif.org/ver10/device/wsdl</tds:Namespace><tds:XAddr>http://192.168.4.12/onvif/device_service</tds:XAddr><tds:Capabilities> <tds:Capabilities xmlns:tds=\"http://www.onvif.org/ver10/device/wsdl\"><tds:Network DHCPv6=\"true\" NTP=\"1\" DynDNS=\"true\" IPVersion6=\"true\" ZeroConfiguration=\"true\" IPFilter=\"true\"></tds:Network><tds:Security HttpDigest=\"true\" UsernameToken=\"true\" DefaultAccessPolicy=\"true\" AccessPolicyConfig=\"true\" OnboardKeyGeneration=\"true\" TLS1.2=\"true\" TLS1.1=\"true\" TLS1.0=\"true\"></tds:Security><tds:System SystemLogging=\"true\" DiscoveryBye=\"true\" DiscoveryResolve=\"true\"></tds:System></tds:Capabilities></tds:Capabilities><tds:Version><tt:Major>2</tt:Major><tt:Minor>21</tt:Minor></tds:Version></tds:Service><tds:Service><tds:Namespace>http://www.onvif.org/ver10/deviceIO/wsdl</tds:Namespace><tds:XAddr>http://192.168.4.12/onvif/services</tds:XAddr><tds:Capabilities> <tmd:Capabilities xmlns:tmd=\"http://www.onvif.org/ver10/deviceIO/wsdl\" DigitalInputOptions=\"true\" DigitalInputs=\"4\" SerialPorts=\"0\" RelayOutputs=\"0\" AudioOutputs=\"1\" AudioSources=\"1\" VideoOutputs=\"0\" VideoSources=\"1\"></tmd:Capabilities></tds:Capabilities><tds:Version><tt:Major>2</tt:Major><tt:Minor>61</tt:Minor></tds:Version></tds:Service><tds:Service><tds:Namespace>http://www.onvif.org/ver10/recording/wsdl</tds:Namespace><tds:XAddr>http://192.168.4.12/onvif/services</tds:XAddr><tds:Capabilities> <trc:Capabilities xmlns:trc=\"http://www.onvif.org/ver10/recording/wsdl\" Options=\"true\" MaxRecordingJobs=\"32\" MaxRecordings=\"32\" MaxTotalRate=\"2.14748365E+09\" MaxRate=\"2.14748365E+09\" Encoding=\"H264 AAC\" DynamicRecordings=\"true\"><tt:CapabilitiesExtension><RecordingCapabilities ReceiverSource=\"false\" MediaProfileSource=\"true\" DynamicRecordings=\"true\" DynamicTracks=\"false\" MaxStringLength=\"4096\"></RecordingCapabilities></tt:CapabilitiesExtension></trc:Capabilities></tds:Capabilities><tds:Version><tt:Major>2</tt:Major><tt:Minor>50</tt:Minor></tds:Version></tds:Service><tds:Service><tds:Namespace>http://www.onvif.org/ver10/replay/wsdl</tds:Namespace><tds:XAddr>http://192.168.4.12/onvif/services</tds:XAddr><tds:Capabilities> <trp:Capabilities xmlns:trp=\"http://www.onvif.org/ver10/replay/wsdl\" RTP_RTSP_TCP=\"true\" SessionTimeoutRange=\"0 4294967295\" ReversePlayback=\"false\"><tt:CapabilitiesExtension><RecordingCapabilities ReceiverSource=\"false\" MediaProfileSource=\"true\" DynamicRecordings=\"true\" DynamicTracks=\"false\" MaxStringLength=\"4096\"></RecordingCapabilities></tt:CapabilitiesExtension></trp:Capabilities></tds:Capabilities><tds:Version><tt:Major>2</tt:Major><tt:Minor>21</tt:Minor></tds:Version></tds:Service><tds:Service><tds:Namespace>http://www.onvif.org/ver10/media/wsdl</tds:Namespace><tds:XAddr>http://192.168.4.12/onvif/services</tds:XAddr><tds:Capabilities> <trt:Capabilities xmlns:trt=\"http://www.onvif.org/ver10/media/wsdl\" Rotation=\"true\" SnapshotUri=\"true\"><trt:ProfileCapabilities MaximumNumberOfProfiles=\"32\"></trt:ProfileCapabilities><trt:StreamingCapabilities RTP_RTSP_TCP=\"true\" RTP_TCP=\"true\" RTPMulticast=\"true\"></trt:StreamingCapabilities></trt:Capabilities></tds:Capabilities><tds:Version><tt:Major>2</tt:Major><tt:Minor>60</tt:Minor></tds:Version></tds:Service><tds:Service><tds:Namespace>http://www.onvif.org/ver10/search/wsdl</tds:Namespace><tds:XAddr>http://192.168.4.12/onvif/services</tds:XAddr><tds:Capabilities> <tse:Capabilities xmlns:tse=\"http://www.onvif.org/ver10/search/wsdl\" GeneralStartEvents=\"false\" MetadataSearch=\"false\"><tt:CapabilitiesExtension><RecordingCapabilities ReceiverSource=\"false\" MediaProfileSource=\"true\" DynamicRecordings=\"true\" DynamicTracks=\"false\" MaxStringLength=\"4096\"></RecordingCapabilities></tt:CapabilitiesExtension></tse:Capabilities></tds:Capabilities><tds:Version><tt:Major>2</tt:Major><tt:Minor>42</tt:Minor></tds:Version></tds:Service></tds:GetServicesResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>",

                /// Core GetServiceCapabilities
                "trt:GetServiceCapabilities":
                "<?xml version=\"1.0\" encoding=\"UTF-8\"?><SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:SOAP-ENC=\"http://www.w3.org/2003/05/soap-encoding\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:c14n=\"http://www.w3.org/2001/10/xml-exc-c14n#\" xmlns:wsu=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd\" xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\" xmlns:wsse=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd\" xmlns:wsa5=\"http://www.w3.org/2005/08/addressing\" xmlns:xmime=\"http://tempuri.org/xmime.xsd\" xmlns:xop=\"http://www.w3.org/2004/08/xop/include\" xmlns:wsrfbf=\"http://docs.oasis-open.org/wsrf/bf-2\" xmlns:wstop=\"http://docs.oasis-open.org/wsn/t-1\" xmlns:tt=\"http://www.onvif.org/ver10/schema\" xmlns:acert=\"http://www.axis.com/vapix/ws/cert\" xmlns:wsrfr=\"http://docs.oasis-open.org/wsrf/r-2\" xmlns:aa=\"http://www.axis.com/vapix/ws/action1\" xmlns:acertificates=\"http://www.axis.com/vapix/ws/certificates\" xmlns:aentry=\"http://www.axis.com/vapix/ws/entry\" xmlns:aev=\"http://www.axis.com/vapix/ws/event1\" xmlns:aeva=\"http://www.axis.com/vapix/ws/embeddedvideoanalytics1\" xmlns:ali1=\"http://www.axis.com/vapix/ws/light/CommonBinding\" xmlns:ali2=\"http://www.axis.com/vapix/ws/light/IntensityBinding\" xmlns:ali3=\"http://www.axis.com/vapix/ws/light/AngleOfIlluminationBinding\" xmlns:ali4=\"http://www.axis.com/vapix/ws/light/DayNightSynchronizeBinding\" xmlns:ali=\"http://www.axis.com/vapix/ws/light\" xmlns:apc=\"http://www.axis.com/vapix/ws/panopsiscalibration1\" xmlns:arth=\"http://www.axis.com/vapix/ws/recordedtour1\" xmlns:asd=\"http://www.axis.com/vapix/ws/shockdetection\" xmlns:aweb=\"http://www.axis.com/vapix/ws/webserver\" xmlns:tan1=\"http://www.onvif.org/ver20/analytics/wsdl/RuleEngineBinding\" xmlns:tan2=\"http://www.onvif.org/ver20/analytics/wsdl/AnalyticsEngineBinding\" xmlns:tan=\"http://www.onvif.org/ver20/analytics/wsdl\" xmlns:tds=\"http://www.onvif.org/ver10/device/wsdl\" xmlns:tev1=\"http://www.onvif.org/ver10/events/wsdl/NotificationProducerBinding\" xmlns:tev2=\"http://www.onvif.org/ver10/events/wsdl/EventBinding\" xmlns:tev3=\"http://www.onvif.org/ver10/events/wsdl/SubscriptionManagerBinding\" xmlns:wsnt=\"http://docs.oasis-open.org/wsn/b-2\" xmlns:tev4=\"http://www.onvif.org/ver10/events/wsdl/PullPointSubscriptionBinding\" xmlns:tev=\"http://www.onvif.org/ver10/events/wsdl\" xmlns:timg=\"http://www.onvif.org/ver20/imaging/wsdl\" xmlns:tmd=\"http://www.onvif.org/ver10/deviceIO/wsdl\" xmlns:tptz=\"http://www.onvif.org/ver20/ptz/wsdl\" xmlns:trc=\"http://www.onvif.org/ver10/recording/wsdl\" xmlns:trp=\"http://www.onvif.org/ver10/replay/wsdl\" xmlns:trt=\"http://www.onvif.org/ver10/media/wsdl\" xmlns:tse=\"http://www.onvif.org/ver10/search/wsdl\" xmlns:ter=\"http://www.onvif.org/ver10/error\" xmlns:tns1=\"http://www.onvif.org/ver10/topics\" xmlns:tnsaxis=\"http://www.axis.com/2009/event/topics\"><SOAP-ENV:Header></SOAP-ENV:Header><SOAP-ENV:Body><tds:GetServiceCapabilitiesResponse><tds:Capabilities><tds:Network DHCPv6=\"true\" NTP=\"1\" DynDNS=\"true\" IPVersion6=\"true\" ZeroConfiguration=\"true\" IPFilter=\"true\"></tds:Network><tds:Security HttpDigest=\"true\" UsernameToken=\"true\" DefaultAccessPolicy=\"true\" AccessPolicyConfig=\"true\" OnboardKeyGeneration=\"true\" TLS1.2=\"true\" TLS1.1=\"true\" TLS1.0=\"true\"></tds:Security><tds:System SystemLogging=\"true\" DiscoveryBye=\"true\" DiscoveryResolve=\"true\"></tds:System></tds:Capabilities></tds:GetServiceCapabilitiesResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>",
                
                /// Core GetScopes
                "trt:GetScopes":
                "<?xml version=\"1.0\" encoding=\"UTF-8\"?><SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:SOAP-ENC=\"http://www.w3.org/2003/05/soap-encoding\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:c14n=\"http://www.w3.org/2001/10/xml-exc-c14n#\" xmlns:wsu=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd\" xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\" xmlns:wsse=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd\" xmlns:wsa5=\"http://www.w3.org/2005/08/addressing\" xmlns:xmime=\"http://tempuri.org/xmime.xsd\" xmlns:xop=\"http://www.w3.org/2004/08/xop/include\" xmlns:wsrfbf=\"http://docs.oasis-open.org/wsrf/bf-2\" xmlns:wstop=\"http://docs.oasis-open.org/wsn/t-1\" xmlns:tt=\"http://www.onvif.org/ver10/schema\" xmlns:acert=\"http://www.axis.com/vapix/ws/cert\" xmlns:wsrfr=\"http://docs.oasis-open.org/wsrf/r-2\" xmlns:aa=\"http://www.axis.com/vapix/ws/action1\" xmlns:acertificates=\"http://www.axis.com/vapix/ws/certificates\" xmlns:aentry=\"http://www.axis.com/vapix/ws/entry\" xmlns:aev=\"http://www.axis.com/vapix/ws/event1\" xmlns:aeva=\"http://www.axis.com/vapix/ws/embeddedvideoanalytics1\" xmlns:ali1=\"http://www.axis.com/vapix/ws/light/CommonBinding\" xmlns:ali2=\"http://www.axis.com/vapix/ws/light/IntensityBinding\" xmlns:ali3=\"http://www.axis.com/vapix/ws/light/AngleOfIlluminationBinding\" xmlns:ali4=\"http://www.axis.com/vapix/ws/light/DayNightSynchronizeBinding\" xmlns:ali=\"http://www.axis.com/vapix/ws/light\" xmlns:apc=\"http://www.axis.com/vapix/ws/panopsiscalibration1\" xmlns:arth=\"http://www.axis.com/vapix/ws/recordedtour1\" xmlns:asd=\"http://www.axis.com/vapix/ws/shockdetection\" xmlns:aweb=\"http://www.axis.com/vapix/ws/webserver\" xmlns:tan1=\"http://www.onvif.org/ver20/analytics/wsdl/RuleEngineBinding\" xmlns:tan2=\"http://www.onvif.org/ver20/analytics/wsdl/AnalyticsEngineBinding\" xmlns:tan=\"http://www.onvif.org/ver20/analytics/wsdl\" xmlns:tds=\"http://www.onvif.org/ver10/device/wsdl\" xmlns:tev1=\"http://www.onvif.org/ver10/events/wsdl/NotificationProducerBinding\" xmlns:tev2=\"http://www.onvif.org/ver10/events/wsdl/EventBinding\" xmlns:tev3=\"http://www.onvif.org/ver10/events/wsdl/SubscriptionManagerBinding\" xmlns:wsnt=\"http://docs.oasis-open.org/wsn/b-2\" xmlns:tev4=\"http://www.onvif.org/ver10/events/wsdl/PullPointSubscriptionBinding\" xmlns:tev=\"http://www.onvif.org/ver10/events/wsdl\" xmlns:timg=\"http://www.onvif.org/ver20/imaging/wsdl\" xmlns:tmd=\"http://www.onvif.org/ver10/deviceIO/wsdl\" xmlns:tptz=\"http://www.onvif.org/ver20/ptz/wsdl\" xmlns:trc=\"http://www.onvif.org/ver10/recording/wsdl\" xmlns:trp=\"http://www.onvif.org/ver10/replay/wsdl\" xmlns:trt=\"http://www.onvif.org/ver10/media/wsdl\" xmlns:tse=\"http://www.onvif.org/ver10/search/wsdl\" xmlns:ter=\"http://www.onvif.org/ver10/error\" xmlns:tns1=\"http://www.onvif.org/ver10/topics\" xmlns:tnsaxis=\"http://www.axis.com/2009/event/topics\"><SOAP-ENV:Body><tds:GetScopesResponse><tds:Scopes><tt:ScopeDef>Fixed</tt:ScopeDef><tt:ScopeItem>onvif://www.onvif.org/Profile/Streaming</tt:ScopeItem></tds:Scopes><tds:Scopes><tt:ScopeDef>Fixed</tt:ScopeDef><tt:ScopeItem>onvif://www.onvif.org/Profile/G</tt:ScopeItem></tds:Scopes><tds:Scopes><tt:ScopeDef>Fixed</tt:ScopeDef><tt:ScopeItem>onvif://www.onvif.org/hardware/M5525-E</tt:ScopeItem></tds:Scopes><tds:Scopes><tt:ScopeDef>Fixed</tt:ScopeDef><tt:ScopeItem>onvif://www.onvif.org/name/AXIS%20M5525-E</tt:ScopeItem></tds:Scopes><tds:Scopes><tt:ScopeDef>Configurable</tt:ScopeDef><tt:ScopeItem>onvif://www.onvif.org/location/</tt:ScopeItem></tds:Scopes></tds:GetScopesResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>",
                
                /// Core GetNetworkInterfaces
                "trt:GetNetworkInterfaces":
                "<?xml version=\"1.0\" encoding=\"UTF-8\"?><SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:SOAP-ENC=\"http://www.w3.org/2003/05/soap-encoding\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:c14n=\"http://www.w3.org/2001/10/xml-exc-c14n#\" xmlns:wsu=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd\" xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\" xmlns:wsse=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd\" xmlns:wsa5=\"http://www.w3.org/2005/08/addressing\" xmlns:xmime=\"http://tempuri.org/xmime.xsd\" xmlns:xop=\"http://www.w3.org/2004/08/xop/include\" xmlns:wsrfbf=\"http://docs.oasis-open.org/wsrf/bf-2\" xmlns:wstop=\"http://docs.oasis-open.org/wsn/t-1\" xmlns:tt=\"http://www.onvif.org/ver10/schema\" xmlns:acert=\"http://www.axis.com/vapix/ws/cert\" xmlns:wsrfr=\"http://docs.oasis-open.org/wsrf/r-2\" xmlns:aa=\"http://www.axis.com/vapix/ws/action1\" xmlns:acertificates=\"http://www.axis.com/vapix/ws/certificates\" xmlns:aentry=\"http://www.axis.com/vapix/ws/entry\" xmlns:aev=\"http://www.axis.com/vapix/ws/event1\" xmlns:aeva=\"http://www.axis.com/vapix/ws/embeddedvideoanalytics1\" xmlns:ali1=\"http://www.axis.com/vapix/ws/light/CommonBinding\" xmlns:ali2=\"http://www.axis.com/vapix/ws/light/IntensityBinding\" xmlns:ali3=\"http://www.axis.com/vapix/ws/light/AngleOfIlluminationBinding\" xmlns:ali4=\"http://www.axis.com/vapix/ws/light/DayNightSynchronizeBinding\" xmlns:ali=\"http://www.axis.com/vapix/ws/light\" xmlns:apc=\"http://www.axis.com/vapix/ws/panopsiscalibration1\" xmlns:arth=\"http://www.axis.com/vapix/ws/recordedtour1\" xmlns:asd=\"http://www.axis.com/vapix/ws/shockdetection\" xmlns:aweb=\"http://www.axis.com/vapix/ws/webserver\" xmlns:tan1=\"http://www.onvif.org/ver20/analytics/wsdl/RuleEngineBinding\" xmlns:tan2=\"http://www.onvif.org/ver20/analytics/wsdl/AnalyticsEngineBinding\" xmlns:tan=\"http://www.onvif.org/ver20/analytics/wsdl\" xmlns:tds=\"http://www.onvif.org/ver10/device/wsdl\" xmlns:tev1=\"http://www.onvif.org/ver10/events/wsdl/NotificationProducerBinding\" xmlns:tev2=\"http://www.onvif.org/ver10/events/wsdl/EventBinding\" xmlns:tev3=\"http://www.onvif.org/ver10/events/wsdl/SubscriptionManagerBinding\" xmlns:wsnt=\"http://docs.oasis-open.org/wsn/b-2\" xmlns:tev4=\"http://www.onvif.org/ver10/events/wsdl/PullPointSubscriptionBinding\" xmlns:tev=\"http://www.onvif.org/ver10/events/wsdl\" xmlns:timg=\"http://www.onvif.org/ver20/imaging/wsdl\" xmlns:tmd=\"http://www.onvif.org/ver10/deviceIO/wsdl\" xmlns:tptz=\"http://www.onvif.org/ver20/ptz/wsdl\" xmlns:trc=\"http://www.onvif.org/ver10/recording/wsdl\" xmlns:trp=\"http://www.onvif.org/ver10/replay/wsdl\" xmlns:trt=\"http://www.onvif.org/ver10/media/wsdl\" xmlns:tse=\"http://www.onvif.org/ver10/search/wsdl\" xmlns:ter=\"http://www.onvif.org/ver10/error\" xmlns:tns1=\"http://www.onvif.org/ver10/topics\" xmlns:tnsaxis=\"http://www.axis.com/2009/event/topics\"><SOAP-ENV:Body><tds:GetNetworkInterfacesResponse><tds:NetworkInterfaces token=\"eth0\"><tt:Enabled>true</tt:Enabled><tt:Info><tt:Name>eth0</tt:Name><tt:HwAddress>AC:CC:8E:BE:CC:EA</tt:HwAddress><tt:MTU>1500</tt:MTU></tt:Info><tt:Link><tt:AdminSettings><tt:AutoNegotiation>true</tt:AutoNegotiation><tt:Speed>100</tt:Speed><tt:Duplex>Full</tt:Duplex></tt:AdminSettings><tt:OperSettings><tt:AutoNegotiation>true</tt:AutoNegotiation><tt:Speed>100</tt:Speed><tt:Duplex>Full</tt:Duplex></tt:OperSettings><tt:InterfaceType>6</tt:InterfaceType></tt:Link><tt:IPv4><tt:Enabled>true</tt:Enabled><tt:Config><tt:Manual><tt:Address>192.168.0.90</tt:Address><tt:PrefixLength>24</tt:PrefixLength></tt:Manual><tt:LinkLocal><tt:Address>169.254.148.62</tt:Address><tt:PrefixLength>16</tt:PrefixLength></tt:LinkLocal><tt:FromDHCP><tt:Address>192.168.4.12</tt:Address><tt:PrefixLength>24</tt:PrefixLength></tt:FromDHCP><tt:DHCP>true</tt:DHCP></tt:Config></tt:IPv4><tt:IPv6><tt:Enabled>true</tt:Enabled><tt:Config><tt:AcceptRouterAdvert>true</tt:AcceptRouterAdvert><tt:DHCP>Auto</tt:DHCP><tt:LinkLocal><tt:Address>fe80::aecc:8eff:febe:ccea</tt:Address><tt:PrefixLength>64</tt:PrefixLength></tt:LinkLocal><tt:FromDHCP><tt:Address>fc00::173</tt:Address><tt:PrefixLength>128</tt:PrefixLength></tt:FromDHCP><tt:FromRA><tt:Address>fc00::aecc:8eff:febe:ccea</tt:Address><tt:PrefixLength>64</tt:PrefixLength></tt:FromRA></tt:Config></tt:IPv6></tds:NetworkInterfaces></tds:GetNetworkInterfacesResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>",
                
                /// Core GetCapabilities
                "trt:GetCapabilities":
                "<?xml version=\"1.0\" encoding=\"UTF-8\"?><SOAP-ENV:Envelope xmlns:SOAP-ENV=\"http://www.w3.org/2003/05/soap-envelope\" xmlns:SOAP-ENC=\"http://www.w3.org/2003/05/soap-encoding\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:c14n=\"http://www.w3.org/2001/10/xml-exc-c14n#\" xmlns:wsu=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd\" xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\" xmlns:wsse=\"http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd\" xmlns:wsa5=\"http://www.w3.org/2005/08/addressing\" xmlns:xmime=\"http://tempuri.org/xmime.xsd\" xmlns:xop=\"http://www.w3.org/2004/08/xop/include\" xmlns:wsrfbf=\"http://docs.oasis-open.org/wsrf/bf-2\" xmlns:wstop=\"http://docs.oasis-open.org/wsn/t-1\" xmlns:tt=\"http://www.onvif.org/ver10/schema\" xmlns:acert=\"http://www.axis.com/vapix/ws/cert\" xmlns:wsrfr=\"http://docs.oasis-open.org/wsrf/r-2\" xmlns:aa=\"http://www.axis.com/vapix/ws/action1\" xmlns:acertificates=\"http://www.axis.com/vapix/ws/certificates\" xmlns:aentry=\"http://www.axis.com/vapix/ws/entry\" xmlns:aev=\"http://www.axis.com/vapix/ws/event1\" xmlns:aeva=\"http://www.axis.com/vapix/ws/embeddedvideoanalytics1\" xmlns:ali1=\"http://www.axis.com/vapix/ws/light/CommonBinding\" xmlns:ali2=\"http://www.axis.com/vapix/ws/light/IntensityBinding\" xmlns:ali3=\"http://www.axis.com/vapix/ws/light/AngleOfIlluminationBinding\" xmlns:ali4=\"http://www.axis.com/vapix/ws/light/DayNightSynchronizeBinding\" xmlns:ali=\"http://www.axis.com/vapix/ws/light\" xmlns:apc=\"http://www.axis.com/vapix/ws/panopsiscalibration1\" xmlns:arth=\"http://www.axis.com/vapix/ws/recordedtour1\" xmlns:asd=\"http://www.axis.com/vapix/ws/shockdetection\" xmlns:aweb=\"http://www.axis.com/vapix/ws/webserver\" xmlns:tan1=\"http://www.onvif.org/ver20/analytics/wsdl/RuleEngineBinding\" xmlns:tan2=\"http://www.onvif.org/ver20/analytics/wsdl/AnalyticsEngineBinding\" xmlns:tan=\"http://www.onvif.org/ver20/analytics/wsdl\" xmlns:tds=\"http://www.onvif.org/ver10/device/wsdl\" xmlns:tev1=\"http://www.onvif.org/ver10/events/wsdl/NotificationProducerBinding\" xmlns:tev2=\"http://www.onvif.org/ver10/events/wsdl/EventBinding\" xmlns:tev3=\"http://www.onvif.org/ver10/events/wsdl/SubscriptionManagerBinding\" xmlns:wsnt=\"http://docs.oasis-open.org/wsn/b-2\" xmlns:tev4=\"http://www.onvif.org/ver10/events/wsdl/PullPointSubscriptionBinding\" xmlns:tev=\"http://www.onvif.org/ver10/events/wsdl\" xmlns:timg=\"http://www.onvif.org/ver20/imaging/wsdl\" xmlns:tmd=\"http://www.onvif.org/ver10/deviceIO/wsdl\" xmlns:tptz=\"http://www.onvif.org/ver20/ptz/wsdl\" xmlns:trc=\"http://www.onvif.org/ver10/recording/wsdl\" xmlns:trp=\"http://www.onvif.org/ver10/replay/wsdl\" xmlns:trt=\"http://www.onvif.org/ver10/media/wsdl\" xmlns:tse=\"http://www.onvif.org/ver10/search/wsdl\" xmlns:ter=\"http://www.onvif.org/ver10/error\" xmlns:tns1=\"http://www.onvif.org/ver10/topics\" xmlns:tnsaxis=\"http://www.axis.com/2009/event/topics\"><SOAP-ENV:Header></SOAP-ENV:Header><SOAP-ENV:Body><tds:GetCapabilitiesResponse><tds:Capabilities><tt:Device><tt:XAddr>http://192.168.4.12/onvif/device_service</tt:XAddr><tt:Network><tt:IPFilter>true</tt:IPFilter><tt:ZeroConfiguration>true</tt:ZeroConfiguration><tt:IPVersion6>true</tt:IPVersion6><tt:DynDNS>true</tt:DynDNS></tt:Network><tt:System><tt:DiscoveryResolve>true</tt:DiscoveryResolve><tt:DiscoveryBye>true</tt:DiscoveryBye><tt:RemoteDiscovery>false</tt:RemoteDiscovery><tt:SystemBackup>false</tt:SystemBackup><tt:SystemLogging>true</tt:SystemLogging><tt:FirmwareUpgrade>false</tt:FirmwareUpgrade><tt:SupportedVersions><tt:Major>1</tt:Major><tt:Minor>2</tt:Minor></tt:SupportedVersions></tt:System><tt:IO><tt:InputConnectors>4</tt:InputConnectors><tt:RelayOutputs>0</tt:RelayOutputs></tt:IO><tt:Security><tt:TLS1.1>true</tt:TLS1.1><tt:TLS1.2>true</tt:TLS1.2><tt:OnboardKeyGeneration>true</tt:OnboardKeyGeneration><tt:AccessPolicyConfig>true</tt:AccessPolicyConfig><tt:X.509Token>false</tt:X.509Token><tt:SAMLToken>false</tt:SAMLToken><tt:KerberosToken>false</tt:KerberosToken><tt:RELToken>false</tt:RELToken><tt:Extension><tt:TLS1.0>true</tt:TLS1.0></tt:Extension></tt:Security></tt:Device><tt:Events><tt:XAddr>http://192.168.4.12/onvif/services</tt:XAddr><tt:WSSubscriptionPolicySupport>false</tt:WSSubscriptionPolicySupport><tt:WSPullPointSupport>false</tt:WSPullPointSupport><tt:WSPausableSubscriptionManagerInterfaceSupport>false</tt:WSPausableSubscriptionManagerInterfaceSupport></tt:Events><tt:Media><tt:XAddr>http://192.168.4.12/onvif/services</tt:XAddr><tt:StreamingCapabilities><tt:RTPMulticast>true</tt:RTPMulticast><tt:RTP_TCP>true</tt:RTP_TCP><tt:RTP_RTSP_TCP>true</tt:RTP_RTSP_TCP></tt:StreamingCapabilities><tt:Extension><tt:ProfileCapabilities><tt:MaximumNumberOfProfiles>32</tt:MaximumNumberOfProfiles></tt:ProfileCapabilities></tt:Extension></tt:Media><tt:PTZ><tt:XAddr>http://192.168.4.12/onvif/services</tt:XAddr></tt:PTZ><tt:Extension><tt:DeviceIO><tt:XAddr>http://192.168.4.12/onvif/services</tt:XAddr><tt:VideoSources>1</tt:VideoSources><tt:VideoOutputs>0</tt:VideoOutputs><tt:AudioSources>1</tt:AudioSources><tt:AudioOutputs>1</tt:AudioOutputs><tt:RelayOutputs>0</tt:RelayOutputs></tt:DeviceIO><tt:Recording><tt:XAddr>http://192.168.4.12/onvif/services</tt:XAddr><tt:ReceiverSource>false</tt:ReceiverSource><tt:MediaProfileSource>true</tt:MediaProfileSource><tt:DynamicRecordings>true</tt:DynamicRecordings><tt:DynamicTracks>false</tt:DynamicTracks><tt:MaxStringLength>4096</tt:MaxStringLength></tt:Recording><tt:Search><tt:XAddr>http://192.168.4.12/onvif/services</tt:XAddr><tt:MetadataSearch>false</tt:MetadataSearch></tt:Search><tt:Replay><tt:XAddr>http://192.168.4.12/onvif/services</tt:XAddr></tt:Replay></tt:Extension></tds:Capabilities></tds:GetCapabilitiesResponse></SOAP-ENV:Body></SOAP-ENV:Envelope>"
            ]
        }
    }
}
