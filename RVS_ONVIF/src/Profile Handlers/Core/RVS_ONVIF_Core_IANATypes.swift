/**
 © Copyright 2019, The Great Rift Valley Software Company. All rights reserved.
 
 This code is proprietary and confidential code,
 It is NOT to be reused or combined into any application,
 unless done so, specifically under written license from The Great Rift Valley Software Company.
 
 The Great Rift Valley Software Company: https://riftvalleysoftware.com
 */

/* ###################################################################################################################################### */
/**
 This file is here merely to host a large enum that holds all the IANA types possible.
 */
extension RVS_ONVIF_Core {
    /* ############################################################## */
    /**
     The possible values of the interfaceType property.
     */
    public enum IANA_Types: Int {
        /// none of the following
        case other = 1
        case regular1822 = 2
        case hdh1822 = 3
        case ddnX25 = 4
        case rfc877x25 = 5
        /// for all ethernet-like interfaces, regardless of speed, as per RFC3635
        case ethernetCsmacd = 6
        /// Deprecated via RFC3635 ethernetCsmacd (6) should be used instead
        case iso88023Csmacd = 7
        case iso88024TokenBus = 8
        case iso88025TokenRing = 9
        case iso88026Man = 10
        /// Deprecated via RFC3635 ethernetCsmacd (6) should be used instead
        case starLan = 11
        case proteon10Mbit = 12
        case proteon80Mbit = 13
        case hyperchannel = 14
        case fddi = 15
        case lapb = 16
        case sdlc = 17
        /// DS1-MIB
        case ds1 = 18
        /// Obsolete see DS1-MIB
        case e1 = 19
        /// no longer used see also RFC2127
        case basicISDN = 20
        /// no longer used see also RFC2127
        case primaryISDN = 21
        /// proprietary serial
        case propPointToPointSerial = 22
        case ppp = 23
        case softwareLoopback = 24
        /// CLNP over IP
        case eon = 25
        case ethernet3Mbit = 26
        /// XNS over IP
        case nsip = 27
        /// generic SLIP
        case slip = 28
        /// ULTRA technologies
        case ultra = 29
        /// DS3-MIB
        case ds3 = 30
        /// SMDS, coffee
        case sip = 31
        /// DTE only.
        case frameRelay = 32
        case rs232 = 33
        /// parallel-port
        case para = 34
        /// arcnet
        case arcnet = 35
        /// arcnet plus
        case arcnetPlus = 36
        /// ATM cells
        case atm = 37
        case miox25 = 38
        /// SONET or SDH
        case sonet = 39
        case x25ple = 40
        case iso88022llc = 41
        case localTalk = 42
        case smdsDxi = 43
        /// FRNETSERV-MIB
        case frameRelayService = 44
        case v35 = 45
        case hssi = 46
        case hippi = 47
        /// Generic modem
        case modem = 48
        /// AAL5 over ATM
        case aal5 = 49
        case sonetPath = 50
        case sonetVT = 51
        /// SMDS InterCarrier Interface
        case smdsIcip = 52
        /// proprietary virtual/internal
        case propVirtual = 53
        /// proprietary multiplexing
        case propMultiplexor = 54
        /// 100BaseVG
        case ieee80212 = 55
        /// Fibre Channel
        case fibreChannel = 56
        /// HIPPI interfaces
        case hippiInterface = 57
        /// Obsolete, use either frameRelay(32) or frameRelayService(44).
        case frameRelayInterconnect = 58
        /// ATM Emulated LAN for 802.3
        case aflane8023 = 59
        /// ATM Emulated LAN for 802.5
        case aflane8025 = 60
        /// ATM Emulated circuit
        case cctEmul = 61
        /// Obsoleted via RFC3635 ethernetCsmacd (6) should be used instead
        case fastEther = 62
        /// ISDN and X.25
        case isdn = 63
        /// CCITT V.11/X.21
        case v11 = 64
        /// CCITT V.36
        case v36 = 65
        /// CCITT G703 at 64Kbps
        case g703at64k = 66
        /// Obsolete see DS1-MIB
        case g703at2mb = 67
        /// SNA QLLC
        case qllc = 68
        /// Obsoleted via RFC3635 ethernetCsmacd (6) should be used instead
        case fastEtherFX = 69
        /// channel
        case channel = 70
        /// radio spread spectrum
        case ieee80211 = 71
        /// IBM System 360/370 OEMI Channel
        case ibm370parChan = 72
        /// IBM Enterprise Systems Connection
        case escon = 73
        /// Data Link Switching
        case dlsw = 74
        /// ISDN S/T interface
        case isdns = 75
        /// ISDN U interface
        case isdnu = 76
        /// Link Access Protocol D
        case lapd = 77
        /// IP Switching Objects
        case ipSwitch = 78
        /// Remote Source Route Bridging
        case rsrb = 79
        /// ATM Logical Port
        case atmLogical = 80
        /// Digital Signal Level 0
        case ds0 = 81
        /// group of ds0s on the same ds1
        case ds0Bundle = 82
        /// Bisynchronous Protocol
        case bsc = 83
        /// Asynchronous Protocol
        case async = 84
        /// Combat Net Radio
        case cnr = 85
        /// ISO 802.5r DTR
        case iso88025Dtr = 86
        /// Ext Pos Loc Report Sys
        case eplrs = 87
        /// Appletalk Remote Access Protocol
        case arap = 88
        /// Proprietary Connectionless Protocol
        case propCnls = 89
        /// CCITT-ITU X.29 PAD Protocol
        case hostPad = 90
        /// CCITT-ITU X.3 PAD Facility
        case termPad = 91
        /// Multiproto Interconnect over FR
        case frameRelayMPI = 92
        /// CCITT-ITU X213
        case x213 = 93
        /// Asymmetric Digital Subscriber Loop
        case adsl = 94
        /// Rate-Adapt. Digital Subscriber Loop
        case radsl = 95
        /// Symmetric Digital Subscriber Loop
        case sdsl = 96
        /// Very H-Speed Digital Subscrib. Loop
        case vdsl = 97
        /// ISO 802.5 CRFP
        case iso88025CRFPInt = 98
        /// Myricom Myrinet
        case myrinet = 99
        /// voice recEive and transMit
        case voiceEM = 100
        /// voice Foreign Exchange Office
        case voiceFXO = 101
        /// voice Foreign Exchange Station
        case voiceFXS = 102
        /// voice encapsulation
        case voiceEncap = 103
        /// voice over IP encapsulation
        case voiceOverIp = 104
        /// ATM DXI
        case atmDxi = 105
        /// ATM FUNI
        case atmFuni = 106
        /// ATM IMA
        case atmIma  = 107
        /// PPP Multilink Bundle
        case pppMultilinkBundle = 108
        /// IBM ipOverCdlc
        case ipOverCdlc  = 109
        /// IBM Common Link Access to Workstn
        case ipOverClaw  = 110
        /// IBM stackToStack
        case stackToStack  = 111
        /// IBM VIPA
        case virtualIpAddress  = 112
        /// IBM multi-protocol channel support
        case mpc  = 113
        /// IBM ipOverAtm
        case ipOverAtm  = 114
        /// ISO 802.5j Fiber Token Ring
        case iso88025Fiber  = 115
        /// IBM twinaxial data link control
        case tdlc  = 116
        /// Obsoleted via RFC3635 ethernetCsmacd (6) should be used instead
        case gigabitEthernet  = 117
        /// HDLC
        case hdlc  = 118
        /// LAP F
        case lapf  = 119
        /// V.37
        case v37  = 120
        /// Multi-Link Protocol
        case x25mlp  = 121
        /// X25 Hunt Group
        case x25huntGroup  = 122
        /// Transp HDLC
        case transpHdlc  = 123
        /// Interleave channel
        case interleave  = 124
        /// Fast channel
        case fast  = 125
        /// IP (for APPN HPR in IP networks)
        case ip  = 126
        /// CATV Mac Layer
        case docsCableMaclayer  = 127
        /// CATV Downstream interface
        case docsCableDownstream  = 128
        /// CATV Upstream interface
        case docsCableUpstream  = 129
        /// Avalon Parallel Processor
        case a12MppSwitch  = 130
        /// Encapsulation interface
        case tunnel  = 131
        /// coffee pot
        case coffee  = 132
        /// Circuit Emulation Service
        case ces  = 133
        /// ATM Sub Interface
        case atmSubInterface  = 134
        /// Layer 2 Virtual LAN using 802.1Q
        case l2vlan  = 135
        /// Layer 3 Virtual LAN using IP
        case l3ipvlan  = 136
        /// Layer 3 Virtual LAN using IPX
        case l3ipxvlan  = 137
        /// IP over Power Lines
        case digitalPowerline  = 138
        /// Multimedia Mail over IP
        case mediaMailOverIp  = 139
        /// Dynamic syncronous Transfer Mode
        case dtm  = 140
        /// Data Communications Network
        case dcn  = 141
        /// IP Forwarding Interface
        case ipForward  = 142
        /// Multi-rate Symmetric DSL
        case msdsl  = 143
        /// IEEE1394 High Performance Serial Bus
        case ieee1394  = 144
        ///   HIPPI-6400
        case if_gsn  = 145
        /// DVB-RCC MAC Layer
        case dvbRccMacLayer  = 146
        /// DVB-RCC Downstream Channel
        case dvbRccDownstream  = 147
        /// DVB-RCC Upstream Channel
        case dvbRccUpstream  = 148
        /// ATM Virtual Interface
        case atmVirtual  = 149
        /// MPLS Tunnel Virtual Interface
        case mplsTunnel  = 150
        /// Spatial Reuse Protocol
        case srp  = 151
        /// Voice Over ATM
        case voiceOverAtm  = 152
        /// Voice Over Frame Relay
        case voiceOverFrameRelay  = 153
        /// Digital Subscriber Loop over ISDN
        case idsl  = 154
        /// Avici Composite Link Interface
        case compositeLink  = 155
        /// SS7 Signaling Link
        case ss7SigLink  = 156
        ///  Prop. P2P wireless interface
        case propWirelessP2P  = 157
        /// Frame Forward Interface
        case frForward  = 158
        /// Multiprotocol over ATM AAL5
        case rfc1483  = 159
        /// USB Interface
        case usb  = 160
        /// IEEE 802.3ad Link Aggregate
        case ieee8023adLag  = 161
        /// BGP Policy Accounting
        case bgppolicyaccounting  = 162
        /// FRF .16 Multilink Frame Relay
        case frf16MfrBundle  = 163
        /// H323 Gatekeeper
        case h323Gatekeeper  = 164
        /// H323 Voice and Video Proxy
        case h323Proxy  = 165
        /// MPLS
        case mpls  = 166
        /// Multi-frequency signaling link
        case mfSigLink  = 167
        /// High Bit-Rate DSL - 2nd generation
        case hdsl2  = 168
        /// Multirate HDSL2
        case shdsl  = 169
        /// Facility Data Link 4Kbps on a DS1
        case ds1FDL  = 170
        /// Packet over SONET/SDH Interface
        case pos  = 171
        /// DVB-ASI Input
        case dvbAsiIn  = 172
        /// DVB-ASI Output
        case dvbAsiOut  = 173
        /// Power Line Communtications
        case plc  = 174
        /// Non Facility Associated Signaling
        case nfas  = 175
        /// TR008
        case tr008  = 176
        /// Remote Digital Terminal
        case gr303RDT  = 177
        /// Integrated Digital Terminal
        case gr303IDT  = 178
        /// ISUP
        case isup  = 179
        /// Cisco proprietary Maclayer
        case propDocsWirelessMaclayer  = 180
        /// Cisco proprietary Downstream
        case propDocsWirelessDownstream  = 181
        /// Cisco proprietary Upstream
        case propDocsWirelessUpstream  = 182
        /// HIPERLAN Type 2 Radio Interface use of this iftype for IEEE 802.16 WMAN interfaces as per IEEE Std 802.16f is deprecated and ifType 237 should be used instead.
        case hiperlan2  = 183
        /// SONET Overhead Channel
        case sonetOverheadChannel  = 185
        /// Digital Wrapper
        case digitalWrapperOverheadChannel  = 186
        /// ATM adaptation layer 2
        case aal2  = 187
        /// MAC layer over radio links
        case radioMAC  = 188
        /// ATM over radio links
        case atmRadio  = 189
        /// Inter Machine Trunks
        case imt  = 190
        /// Multiple Virtual Lines DSL
        case mvl  = 191
        /// Long Reach DSL
        case reachDSL  = 192
        /// Frame Relay DLCI End Point
        case frDlciEndPt  = 193
        /// ATM VCI End Point
        case atmVciEndPt  = 194
        /// Optical Channel
        case opticalChannel  = 195
        /// Optical Transport
        case opticalTransport  = 196
        ///  Proprietary ATM
        case propAtm  = 197
        /// Voice Over Cable Interface
        case voiceOverCable  = 198
        /// Infiniband
        case infiniband  = 199
        /// TE Link
        case teLink  = 200
        /// Q.2931
        case q2931  = 201
        /// Virtual Trunk Group
        case virtualTg  = 202
        /// SIP Trunk Group
        case sipTg  = 203
        /// SIP Signaling
        case sipSig  = 204
        /// CATV Upstream Channel
        case docsCableUpstreamChannel  = 205
        /// Acorn Econet
        case econet  = 206
        /// FSAN 155Mb Symetrical PON interface
        case pon155  = 207
        /// FSAN622Mb Symetrical PON interface
        case pon622  = 208
        /// Transparent bridge interface
        case bridge  = 209
        /// Interface common to multiple lines
        case linegroup  = 210
        /// voice E&M Feature Group D
        case voiceEMFGD  = 211
        /// voice FGD Exchange Access North American
        case voiceFGDEANA  = 212
        /// voice Direct Inward Dialing
        case voiceDID  = 213
        /// MPEG transport interface
        case mpegTransport  = 214
        /// 6to4 interface (DEPRECATED)
        case sixToFour  = 215
        /// GTP (GPRS Tunneling Protocol)
        case gtp  = 216
        /// Paradyne EtherLoop 1
        case pdnEtherLoop1  = 217
        /// Paradyne EtherLoop 2
        case pdnEtherLoop2  = 218
        /// Optical Channel Group
        case opticalChannelGroup  = 219
        /// HomePNA ITU-T G.989
        case homepna  = 220
        /// Generic Framing Procedure (GFP)
        case gfp  = 221
        /// Layer 2 Virtual LAN using Cisco ISL
        case ciscoISLvlan  = 222
        /// Acteleis proprietary MetaLOOP High Speed Link
        case actelisMetaLOOP  = 223
        /// FCIP Link
        case fcipLink  = 224
        /// Resilient Packet Ring Interface Type
        case rpr  = 225
        /// RF Qam Interface
        case qam  = 226
        /// Link Management Protocol
        case lmp  = 227
        /// Cambridge Broadband Networks Limited VectaStar
        case cblVectaStar  = 228
        /// CATV Modular CMTS Downstream Interface
        case docsCableMCmtsDownstream  = 229
        /// Asymmetric Digital Subscriber Loop Version 2 (DEPRECATED/OBSOLETED - please use adsl2plus 238 instead)
        case adsl2  = 230
        /// MACSecControlled
        case macSecControlledIF  = 231
        /// MACSecUncontrolled
        case macSecUncontrolledIF  = 232
        /// Avici Optical Ethernet Aggregate
        case aviciOpticalEther  = 233
        /// atmbond
        case atmbond  = 234
        /// voice FGD Operator Services
        case voiceFGDOS  = 235
        /// MultiMedia over Coax Alliance (MoCA) Interface as documented in information provided privately to IANA
        case mocaVersion1  = 236
        /// IEEE 802.16 WMAN interface
        case ieee80216WMAN  = 237
        /// Asymmetric Digital Subscriber Loop Version 2, Version 2 Plus and all variants
        case adsl2plus  = 238
        /// DVB-RCS MAC Layer
        case dvbRcsMacLayer  = 239
        /// DVB Satellite TDM
        case dvbTdm  = 240
        /// DVB-RCS TDMA
        case dvbRcsTdma  = 241
        /// LAPS based on ITU-T X.86/Y.1323
        case x86Laps  = 242
        /// 3GPP WWAN
        case wwanPP  = 243
        /// 3GPP2 WWAN
        case wwanPP2  = 244
        /// voice P-phone EBS physical interface
        case voiceEBS  = 245
        /// Pseudowire interface type
        case ifPwType  = 246
        /// Internal LAN on a bridge per IEEE 802.1ap
        case ilan  = 247
        /// Provider Instance Port on a bridge per IEEE 802.1ah PBB
        case pip  = 248
        /// Alcatel-Lucent Ethernet Link Protection
        case aluELP  = 249
        /// Gigabit-capable passive optical networks (G-PON) as per ITU-T G.948
        case gpon  = 250
        /// Very high speed digital subscriber line Version 2 (as per ITU-T Recommendation G.993.2)
        case vdsl2  = 251
        /// WLAN Profile Interface
        case capwapDot11Profile  = 252
        /// WLAN BSS Interface
        case capwapDot11Bss  = 253
        /// WTP Virtual Radio Interface
        case capwapWtpVirtualRadio  = 254
        /// bitsport
        case bits  = 255
        /// DOCSIS CATV Upstream RF Port
        case docsCableUpstreamRfPort  = 256
        /// CATV downstream RF port
        case cableDownstreamRfPort  = 257
        /// VMware Virtual Network Interface
        case vmwareVirtualNic  = 258
        /// IEEE 802.15.4 WPAN interface
        case ieee802154  = 259
        /// OTN Optical Data Unit
        case otnOdu  = 260
        /// OTN Optical channel Transport Unit
        case otnOtu  = 261
        /// VPLS Forwarding Instance Interface Type
        case ifVfiType  = 262
        /// G.998.1 bonded interface
        case g9981  = 263
        /// G.998.2 bonded interface
        case g9982  = 264
        /// G.998.3 bonded interface
        case g9983  = 265
        /// Ethernet Passive Optical Networks (E-PON)
        case aluEpon  = 266
        /// EPON Optical Network Unit
        case aluEponOnu  = 267
        /// EPON physical User to Network interface
        case aluEponPhysicalUni  = 268
        /// The emulation of a point-to-point link over the EPON layer
        case aluEponLogicalLink  = 269
        /// GPON Optical Network Unit
        case aluGponOnu  = 270
        /// GPON physical User to Network interface
        case aluGponPhysicalUni  = 271
        /// VMware NIC Team
        case vmwareNicTeam  = 272
        /// CATV Downstream OFDM interface
        case docsOfdmDownstream  = 277
        /// CATV Upstream OFDMA interface
        case docsOfdmaUpstream  = 278
        /// G.fast port
        case gfast  = 279
        /// SDCI (IO-Link)
        case sdci  = 280
        /// Xbox wireless
        case xboxWireless  = 281
        /// FastDSL
        case fastdsl  = 282
        /// Cable SCTE 55-1 OOB Forward Channel
        case docsCableScte55d1FwdOob  = 283
        /// Cable SCTE 55-1 OOB Return Channel
        case docsCableScte55d1RetOob  = 284
        /// Cable SCTE 55-2 OOB Downstream Channel
        case docsCableScte55d2DsOob  = 285
        /// Cable SCTE 55-2 OOB Upstream Channel
        case docsCableScte55d2UsOob  = 286
        /// Cable Narrowband Digital Forward
        case docsCableNdf  = 287
        /// Cable Narrowband Digital Return
        case docsCableNdr  = 288
        /// Packet Transfer Mode
        case ptm  = 289
        /// G.hn port
        case ghn  = 290
        /// Optical Tributary Signal
        case otnOtsi  = 291
        /// OTN OTUCn
        case otnOtuc  = 292
        /// OTN ODUC
        case otnOduc  = 293
        /// OTN OTUC Signal
        case otnOtsig  = 294
        /// air interface of a single microwave carrier
        case microwaveCarrierTermination  = 295
        /// radio link interface for one or several aggregated microwave carriers
        case microwaveRadioLinkTerminal = 296
    }
}
