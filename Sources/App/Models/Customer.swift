import Vapor
import FluentProvider
import HTTP

final class Customer: Model {
    let storage = Storage()

    var name: String

    /// The column names in the database
    static let idKey = "id"
    static let nameKey = "name"

    init(name: String) {
        self.name = name
    }

    init(row: Row) throws {
        name = try row.get(Customer.nameKey)
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Customer.nameKey, name)
        return row
    }
}

// MARK: Fluent Preparation
extension Customer: Preparation {

    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Customer.nameKey)
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
            name: json.get(Customer.nameKey)
        )
    }

    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Customer.idKey, id)
        try json.set(Customer.nameKey, name)
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
            // If the request contains a String at key "content"
            // the setter callback will be called.
            UpdateableKey(Customer.nameKey, String.self) { customer, name in
                customer.name = name
            }
        ]
    }
}
