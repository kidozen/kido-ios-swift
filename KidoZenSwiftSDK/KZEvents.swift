//
//  KZEvents.swift
//  KidoZen
//
//  Created by Nicolas Miyasato on 10/27/14.
//  Copyright (c) 2014 KidoZen. All rights reserved.
//

import Foundation

class KZEvents {
    let kEventsFilename = "kEventsFilename";

    var events : [KZEvent]?

    init() {
        events = []
    }

    init(events:[KZEvent]) {
        if countElements(events) > 0 {
            self.events = events
        }
    }
    
    class func eventsFromDisk() -> KZEvents {
        // Read from disk.
        // TODO:
        return KZEvents()
    }
    
    func removeSavedEvents() {
        let fm = NSFileManager.defaultManager()
        let eventsPath = kEventsFilename.documentsPath()
        
        if (fm.fileExistsAtPath(eventsPath)) {
            fm.removeItemAtPath(eventsPath, error: nil)
        }

    }
    
    func addEvent(event:KZEvent) {
        self.events!.append(event)
    }
    
    func save() {
        let eventsPathFilename = kEventsFilename.documentsPath()
        let arrayEvents = self.events! as NSArray
        if (!arrayEvents.writeToFile(eventsPathFilename, atomically: true)) {
            println("An error occured while saving the events. Could not write to %@", eventsPathFilename);
        }
    }
    
    func removeCurrentEvents() {
        self.events?.removeAll(keepCapacity: false)
    }
    
    
}
