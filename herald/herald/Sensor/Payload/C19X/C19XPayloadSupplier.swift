//
//  C19XPayloadSupplier.swift
//
//  Copyright 2020 VMware, Inc.
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation

///  payload supplier for integration with  backend. Payload data is 8 bytes.
public protocol C19XPayloadDataSupplier : PayloadDataSupplier {
}

///  payload supplier for generating time specific beacon codes based on day codes.
public class ConcretePayloadDataSupplier : C19XPayloadDataSupplier {
    private let dayCodes: DayCodes
    private let beaconCodes: BeaconCodes
    private let emptyPayloadData = PayloadData()
    
    public init(_ sharedSecret: SharedSecret) {
        dayCodes = ConcreteDayCodes(sharedSecret)
        beaconCodes = ConcreteBeaconCodes(dayCodes)
    }
    
    public func legacyPayload(_ timestamp: PayloadTimestamp = PayloadTimestamp(), device: Device?) -> PayloadData? {
        return nil
    }
    
    public func payload(_ timestamp: PayloadTimestamp = PayloadTimestamp(), device: Device?) -> PayloadData? {
        guard let beaconCode = beaconCodes.get(timestamp) else {
            return emptyPayloadData
        }
        return JavaData.longToByteArray(value: beaconCode)
    }
}
