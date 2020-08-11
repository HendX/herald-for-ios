//
//  StatisticsLog.swift
//  
//
//  Created  on 11/08/2020.
//  Copyright © 2020 . All rights reserved.
//

import Foundation

/// CSV contact log for post event analysis and visualisation
class StatisticsLog: NSObject, SensorDelegate {
    private let textFile: TextFile
    private var identifierToPayload: [TargetIdentifier:String] = [:]
    private var payloadToTime: [String:Date] = [:]
    private var payloadToSample: [String:Sample] = [:]
    
    init(filename: String) {
        textFile = TextFile(filename: filename)
    }
    
    private func csv(_ value: String) -> String {
        guard value.contains(",") else {
            return value
        }
        return "\"" + value + "\""
    }
    
    private func add(identifier: TargetIdentifier) {
        guard let payload = identifierToPayload[identifier] else {
            return
        }
        add(payload: payload)
    }

    private func add(payload: String) {
        guard let time = payloadToTime[payload], let sample = payloadToSample[payload] else {
            payloadToTime[payload] = Date()
            payloadToSample[payload] = Sample()
            return
        }
        let now = Date()
        payloadToTime[payload] = now
        sample.add(Double(now.timeIntervalSince(time)))
        write()
    }
    
    private func write() {
        var content = "payload,count,mean,sd,min,max\n"
        var payloadList: [String] = []
        payloadToSample.keys.forEach() { payload in
            payloadList.append(payload)
        }
        payloadList.sort()
        payloadList.forEach() { payload in
            guard let sample = payloadToSample[payload] else {
                return
            }
            guard let mean = sample.mean, let sd = sample.standardDeviation, let min = sample.min, let max = sample.max else {
                return
            }
            content.append("\(csv(payload)),\(sample.count),\(mean),\(sd),\(min),\(max)\n")
        }
        textFile.overwrite(content)
    }


    // MARK:- SensorDelegate
    
    func sensor(_ sensor: SensorType, didDetect: TargetIdentifier) {
    }
    
    func sensor(_ sensor: SensorType, didRead: PayloadData, fromTarget: TargetIdentifier) {
        identifierToPayload[fromTarget] = didRead.shortName
        add(identifier: fromTarget)
    }
    
    func sensor(_ sensor: SensorType, didMeasure: Proximity, fromTarget: TargetIdentifier) {
        add(identifier: fromTarget)
    }
    
    func sensor(_ sensor: SensorType, didShare: [PayloadData], fromTarget: TargetIdentifier) {
        didShare.forEach() { payloadData in
            add(payload: payloadData.shortName)
        }
    }
    
    func sensor(_ sensor: SensorType, didVisit: Location) {
    }
    

}
