import Vapor
import FluentProvider
import HTTP

final class User: Model {
    let storage = Storage()

    var name: String
    var surname: String
    var email: String
    var phone: String
    var password: String

    init(name: String, surname: String, email: String, phone: String, password: String) {
        self.name = name
        self.surname = surname
        self.email = email
        self.phone = phone
        self.password = password
    }

    init(row: Row) throws {
        name = try row.get("name")
        surname = try row.get("surname")
        email = try row.get("email")
        phone = try row.get("phone")
        password = try row.get("password")
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("surname", surname)
        try row.set("email", email)
        try row.set("phone", phone)
        try row.set("password", password)
        return row
    }
}

extension User {
    func physician() throws -> Physician? {
        return try children().first()
    }
}

extension User: Preparation {

    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("name")
            builder.string("surname")
            builder.string("email")
            builder.string("phone")
            builder.string("password")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension User: Timestampable { }
