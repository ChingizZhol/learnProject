//
//  Model.swift
//  CompositionLayout
//
//  Created by nurlanispaew on 28.07.2023.
//

import Foundation

struct LearnPlanOfYear: Codable {
    let iUPSid:         String
    let title:          String
    let documentURL:    String
    let academicYearId: String
    let academicYear:   String
    var semesters:      [Semester]
}

struct Semester: Codable {
    var number:      String
    var disciplines: [Discipline]
}

struct Discipline: Codable {
    var disciplineId:   String
    var disciplineName: DisciplineName
    var lesson:         [Lesson]
}

struct DisciplineName: Codable {
    var nameKk: String
    var nameRu: String
    var nameEn: String
}

struct Lesson: Codable {
    var lessonTypeId: String
    var hours:        String
    var realHours:    String
}
