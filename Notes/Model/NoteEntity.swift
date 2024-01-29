//
//  NoteEntity.swift
//  Notes
//
//  Created by Aliia Satbakova  on 26.01.2024.
//

import Foundation
import RealmSwift

class NoteEntity: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var timestamp: Date = Date()
    @Persisted var text: String = ""
    @Persisted var imageData: Data?
    
    convenience init(text: String, imageData: Data?) {
        self.init()
        self.id = ObjectId.generate()
        self.timestamp = Date()
        self.text = text
        self.imageData = imageData
    }
}
