import Vapor
import FluentProvider
import HTTP

final class Token: Model {
    let storage = Storage()

    let token: String
    let userId: Identifier

    var user: Parent<Token, User> {
        return parent(id: userId)
    }

    init(row: Row) throws {
        token = try row.get("token")
        userId = try row.get("user_id")
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("token", token)
        try row.set("user_id", token)
        return row
    }
}

extension Token: Preparation {

    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("token")
            builder.foreignId(for: User.self)
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Token: Timestampable { }
