import Vapor
import FluentProvider
import HTTP

final class Physician: Model {
    let storage = Storage()

    var userId: Identifier
    var name: String

    var user: Parent<Physician, User> {
        return parent(id: userId)
    }


    init(userId: Identifier, name: String) {
        self.userId = userId
        self.name = name
    }

    init(row: Row) throws {
        name = try row.get("name")
        userId = try row.get("user_id")
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("user_id", userId)
        return row
    }
}

extension Physician: Timestampable { }

extension Physician: Preparation {

    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("name")
            builder.foreignId(for: User.self)
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Physician {
    var services: Siblings<Physician, Service, Pivot<Physician, Service>> {
        return siblings()
    }
}
