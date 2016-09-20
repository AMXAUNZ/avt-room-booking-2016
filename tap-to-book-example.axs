PROGRAM_NAME='tap-to-book-example'
(***********************************************************)
(*  FILE CREATED ON: 09/20/2016  AT: 13:08:34              *)
(***********************************************************)
(*  FILE_LAST_MODIFIED_ON: 09/20/2016  AT: 13:23:27        *)
(***********************************************************)

(***********************************************************)
(*          DEVICE NUMBER DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_DEVICE

dvTP1											= 10001:1:0;
dvTP2											= 10002:1:0;
dvTP3											= 10003:1:0;

dvTP1_RMS										= 10001:9:0;
dvTP2_RMS										= 10002:9:0;
dvTP3_RMS										= 10003:9:0;

vdvRMS                                          = 41001:1:0;
vdvRMSGui                                       = 41002:1:0;

(***********************************************************)
(*               VARIABLE DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_VARIABLE

constant char 		_RMS_SERVER_URL[] 			= 'http://rms-server/rms';
constant char 		_RMS_PASSWORD[] 			= 'password';
persistent char 	_RMS_SERVER_URL_CONFIGURED[100];

constant dev 		dvRMSTP[] = { 
						dvTP1_RMS, 
						dvTP2_RMS, 
						dvTP3_RMS
					}

constant dev 		dvRMSTP_Base[] = { 
						dvTP1, 
						dvTP2, 
						dvTP3
					}

(***********************************************************)
(*                INCLUDE DEFINITIONS GO BELOW             *)
(***********************************************************)

/*
    Refer to the RMS SDK File Dependencies in the
    RMS-ENT RMS Enterprise NetLinx Programmer's Manual.

    These included are located here because RmsApi references the vdvRMS
    device above and defines the RMS data type structures for use below.
*/

// #INCLUDE 'RmsMonitorCommon';				// Included by RmsControlSystemMonitor
// #INCLUDE 'RmsEventListener';				// Included by RmsMonitorCommon
// #INCLUDE 'RmsApi';						// Included by RmsEventListener
// #INCLUDE 'RmsMathUtil';					// Included by RmsApi

   #INCLUDE 'RmsGuiApi';
// #INCLUDE 'RmsApi';						// Included by RmsGuiApi
// #INCLUDE 'RmsMathUtil';					// Included by RmsApi

// #INCLUDE 'RmsSchedulingApi';
// #INCLUDE 'RmsApi';						// Included by RmsSchedulingApi
// #INCLUDE 'RmsMathUtil';					// Included by RmsApi
// #INCLUDE 'RmsSchedulingEventListener';	// Included by RmsSchedulingApi

(***********************************************************)
(*               LATCHING DEFINITIONS GO BELOW             *)
(***********************************************************)
DEFINE_LATCHING

(***********************************************************)
(*       MUTUALLY EXCLUSIVE DEFINITIONS GO BELOW           *)
(***********************************************************)
DEFINE_MUTUALLY_EXCLUSIVE

(***********************************************************)
(*                INCLUDE DEFINITIONS GO BELOW             *)
(***********************************************************)
(* EXAMPLE: INCLUDE '<FILENAME>'                           *)

(***********************************************************)
(*        SUBROUTINE/FUNCTION DEFINITIONS GO BELOW         *)
(***********************************************************)
(* EXAMPLE: DEFINE_FUNCTION <RETURN_TYPE> <NAME> (<PARAMETERS>) *)
(* EXAMPLE: DEFINE_CALL '<NAME>' (<PARAMETERS>) *)

(***********************************************************)
(*                STARTUP CODE GOES BELOW                  *)
(***********************************************************)
DEFINE_START

/*
    RMS Client NetLinx Adapter Module
   
    This module loads the RMS Client into the NetLinx master and provides 
    a NetLinx virtual device to communicate with the RMS Client via 
    SEND_COMMAND, SEND_STRINGS, CHANNELS, and LEVELS.
    
    commons-codec, commons-httpclient, commons-lang, commons-logging, 
    rms-client-netlinx-web, rmsclient-osgi, rmsclient, rmsddeadapter, 
    rmsnlplatform are included by RmsNetLinxAdapter.
*/
DEFINE_MODULE 'RmsNetLinxAdapter_dr4_0_0' mdlRMSNetLinx(vdvRMS);

/*
    AMX Touch Panel Monitor
    
    This NetLinx module contains the source code for monitoring and 
    controlling a touch panel device in RMS.
    
    This module wil register a base set of asset monitoring parameters, 
    metadata properties, and control methods. It will update the monitored
    parameters as changes from the touch panel are detected.

*/
define_module 'RmsTouchPanelMonitor' mdlRmsTouchPanelMonitor1(vdvRMS, dvTP1);
define_module 'RmsTouchPanelMonitor' mdlRmsTouchPanelMonitor2(vdvRMS, dvTP2);
define_module 'RmsTouchPanelMonitor' mdlRmsTouchPanelMonitor3(vdvRMS, dvTP3);

/*
    RMS User Interface Module

    This module is responsible for all the RMS user interface application 
    logic. This includes help requests, maintenance requests, location 
    hotlist, and server display messages.
*/
define_module 'RmsClientGui_dr4_0_0' mdlRmsClientGui(vdvRMSGUI, dvRMSTP, dvRMSTP_Base);

(***********************************************************)
(*                THE EVENTS GO BELOW                      *)
(***********************************************************)
DEFINE_EVENT

data_event[vdvRMSGui] {
    online: {
		RmsSetDefaultEventBookingSubject('Ad-hoc meeting');
		RmsSetDefaultEventBookingBody('Ad-hoc booking made from touch panel');
		RmsSetDefaultEventBookingDuration(15);
		RmsEnableLedSupport(true);
    }
}

custom_event[dvRMSTP_Base, 1, 700] {
    local_var volatile long timer;
    local_var volatile char last_tag[255];
    
    stack_var volatile char organiser[255];
    
    if ((timer >= get_timer - 20) && (last_tag == custom.text)) {
		amx_log(AMX_DEBUG, "'Ignoring repeated NFC tag read'");
    } else {
		switch (custom.text) {
			case '04B0FE3A853280': organiser = 'John Feversham';
			case '04C3FB3A853280': organiser = 'Visitor';
		}
		
		amx_log(AMX_DEBUG, "'NFC tag read: ', custom.text, ' (', organiser, ')'");
		
		if (length_string(organiser)) {
			send_command custom.device, "'^SOU-nfc-tag-accepted.mp3'";
			
			do_push(custom.device.number:dvRMSTP[1].port:custom.device.system, 1307);
			send_command custom.device.number:dvRMSTP[1].port:custom.device.system, "'^TXT-1375,0,Ad-hoc meeting for ', organiser";
			send_command custom.device.number:dvRMSTP[1].port:custom.device.system, "'@PPN-rmsMeetingRequest;rmsSchedulingPage'";
		} else {
			send_command custom.device, "'^SOU-nfc-tag-rejected.mp3'";
		}
    }
    
    timer = get_timer;
    last_tag = custom.text;
}
