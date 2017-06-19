import Vapor
import FluentProvider
import HTTP

final class Customer: Model {
    let storage = Storage()

    var name: String
    var surname: String
    var personalCode: String

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

extension Customer: Timestampable { }

// MARK: Fluent Preparation
extension Customer: Preparation {

    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("name")
            builder.string("surname")
            builder.string("personal_code")
        }
    }

    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON
// How the model converts from / to JSON.
// For example when:
//     - Creating a new Customer (POST /customers)
//     - Fetching a customer (GET /customers, GET /customers/:id)
//
extension Customer: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            name: json.get("attributes.name"),
            surname: json.get("attributes.surname"),
            personalCode: json.get("attributes.personal_code")
        )
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("type", "customers")
        try json.set("id", id)
        try json.set("attributes.name", name)
        try json.set("attributes.surname", surname)
        try json.set("attributes.personal_code", personalCode)
        try json.set("attributes.\(Customer.createdAtKey)", createdAt)
        try json.set("attributes.\(Customer.updatedAtKey)", updatedAt)
        return json
    }
}

// MARK: HTTP
// This allows Customer models to be returned
// directly in route closures
extension Customer: ResponseRepresentable { }

// MARK: Update
// This allows the Customer model to be updated
// dynamically by the request.
extension Customer: Updateable {
    // Updateable keys are called when `customer.update(for: req)` is called.
    // Add as many updateable keys as you like here.
    public static var updateableKeys: [UpdateableKey<Customer>] {
        return [
            UpdateableKey("attributes.name", String.self) { customer, name in
                customer.name = name
            },
            UpdateableKey("attributes.surname", String.self) { customer, surname in
                customer.surname = surname
            },
            UpdateableKey("attributes.personal_code", String.self) { customer, personalCode in
                customer.personalCode = personalCode
            }
        ]
    }
}
