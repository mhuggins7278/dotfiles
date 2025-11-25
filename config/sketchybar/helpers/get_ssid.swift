#!/usr/bin/env swift
import CoreWLAN

if let interface = CWWiFiClient.shared().interface(),
   let ssid = interface.ssid() {
    print(ssid)
}
