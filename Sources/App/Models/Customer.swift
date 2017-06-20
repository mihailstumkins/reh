import Vapor
import FluentProvider
import HTTP

final class Customer: Model {
    let storage = Storage()

    var name: String
    var surname: String
    var personalCode: String

    var orders: Children<Customer, Order> {
        return children()
    }

    init(name: String, surname: String, personalCode: String) {
        self.name = name
        self.surname = surname
        self.personalCode = personalCode
    }

    init(row: Row) throws {
        name = try row.get("name")
        surname = try row.get("surname")
        personalCode = try row.get("personal_code")
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("surname", surname)
        try row.set("personal_code", personalCode)
        return row
    }
}

extension Customer: Preparation {

    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("name")
            builder.string("surname")
            builder.string("personal_code")
        }
        try database.index("personal_code", for: Customer.self)
    }

    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Customer: Timestampable { }
