import Vapor
import FluentProvider
import HTTP

final class Service: Model {
    let storage = Storage()

    var name: String

    init(name: String) {
        self.name = name
    }

    init(row: Row) throws {
        name = try row.get("name")
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        return row
    }
}

extension Service: Preparation {

    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("name")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Service: Timestampable { }
