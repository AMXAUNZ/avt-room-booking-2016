# avt-room-booking-2016

Room booking panel interface deployed at avt offices

This room booking interface was created to be out-of-the-box compatible with the RMS Client Application User Interface Module (RmsClientGui), and systems configured with RPM (Rapid Project Maker).

avt-scheduling-mxd-1001-p.tp5 includes an NFC indicator for tap-to-book functionality on using the NFC sensor in Modero X-Series touch panels. Note that this requires extending the functionality provided by the RmsClientGui module, and is not supported by RPM.

tap-to-book-example.axs contains an example code snippet of how to provide tap-to-book functionality by extending the functionality provided by the RmsClientGui module.

Buttons in this room booking interface have been configured to use port 9 as per the RPM standard. Note that the examples included with the RMS SDK use port 7 - please modify the example or this interface as necessary.
