//
//  NoteViewModel.swift
//  Notes
//
//  Created by Aliia Satbakova  on 26.01.2024.
//

import Foundation
import RealmSwift

class NoteViewModel: ObservableObject {
    var realm: Realm
    
    @Published var notes: Results<NoteEntity>
    @Published var welcomeNote: NoteEntity?
    
    init(realm: Realm = try! Realm()) {
        self.realm = realm
        self.notes = realm.objects(NoteEntity.self)
    }
    
    func createNote() -> NoteEntity {
        let newNote = NoteEntity(text: "", imageData: nil)
        try! realm.write {
            realm.add(newNote)
        }
        return newNote
    }
    
    func deleteNote(_ note: NoteEntity) {
        if isNoteValid(note) {
            try! realm.write {
                realm.delete(note)
            }
        }
        loadNotes() // Reload заметок после удаления
    }
    
    func updateNoteText(note: NoteEntity, newText: String) {
        try! realm.write {
            note.text = newText
            note.timestamp = Date()
        }
    }
    
    func updateNoteImage(note: NoteEntity, image: Data?) {
        try! realm.write {
            note.imageData = image
            note.timestamp = Date()
        }
    }
    
    func isNoteValid(_ note: NoteEntity) -> Bool {
        return !note.isInvalidated
    }
    
    func loadNotes() {
        // Загрузить заметки из Realm
        notes = realm.objects(NoteEntity.self)

        // Проверить, если первый старт launch
        if UserDefaults.standard.bool(forKey: "firstLaunch") == false {
            // Если первый, то создается welcome заметка
            welcomeNote = createWelcomeNote()
            UserDefaults.standard.set(true, forKey: "firstLaunch")
        }
    }

     func createWelcomeNote() -> NoteEntity {
        let welcomeText = "Hello, user! 👋 This is a simple notes app 🦄"
        let welcomeNote = NoteEntity(text: welcomeText, imageData: nil)
         
         // Сохранить welcome заметку в Realm
        let realm = try! Realm()
        try! realm.write {
            realm.add(welcomeNote)
        }
         
        return welcomeNote
    }
}
