import Vapor
import HTTP

import Vapor
import HTTP

/// Here we have a controller that helps facilitate
/// RESTful interactions with our Customers table
final class CustomerController: ResourceRepresentable {

    /// Here we have a controller that helps facilitate
    /// RESTful interactions with our Customers table
    func index(req: Request) throws -> ResponseRepresentable {

        let customers = try Customer.all().makeJSON()
        var json = JSON()
        try json.set("data", customers)
        return json
    }

    /// When consumers call 'POST' on '/customer' with valid JSON
    /// create and save the customer
    func create(request: Request) throws -> ResponseRepresentable {
        let customer = try request.post()
        try customer.save()
        return customer
    }

    /// '/customers/13rd88' we should show that specific customer
    func show(req: Request, customer: Customer) throws -> ResponseRepresentable {
        return customer
    }

    /// When the consumer calls 'DELETE' on a specific resource, ie:
    /// 'customers/l2jd9' we should remove that resource from the database
    func delete(req: Request, customer: Customer) throws -> ResponseRepresentable {
        try customer.delete()
        return Response(status: .ok)
    }

    /// When the consumer calls 'DELETE' on the entire table, ie:
    /// '/customers' we should remove the entire table
    func clear(req: Request) throws -> ResponseRepresentable {
        try Customer.makeQuery().delete()
        return Response(status: .ok)
    }

    /// When the user calls 'PATCH' on a specific resource, we should
    /// update that resource to the new values.
    func update(req: Request, customer: Customer) throws -> ResponseRepresentable {
        try customer.update(for: req)
        try customer.save()
        return customer
    }

    /// When a user calls 'PUT' on a specific resource, we should replace any
    /// values that do not exist in the request with null.
    /// This is equivalent to creating a new Customer with the same ID.
    func replace(req: Request, customer: Customer) throws -> ResponseRepresentable {
        // First attempt to create a new Customer from the supplied JSON.
        // If any required fields are missing, this request will be denied.
        let new = try req.post()

        // Update the customer with all of the properties from
        // the new customer
        customer.name = new.name
        customer.surname = new.surname
        customer.personalCode = new.personalCode
        try customer.save()
        return customer
    }

    /// When making a controller, it is pretty flexible in that it
    /// only expects closures, this is useful for advanced scenarios, but
    /// most of the time, it should look almost identical to this
    /// implementation
    func makeResource() -> Resource<Customer> {
        return Resource(
            index: index,
            store: create,
            show: show,
            update: update,
            replace: replace,
            destroy: delete,
            clear: clear
        )
    }
}

extension Request {
    /// Create a customer from the JSON body
    /// return BadRequest error if invalid
    /// or no JSON
    func post() throws -> Customer {
        guard let json = json else { throw Abort.badRequest }
        return try Customer(json: json)
    }
}

/// Since CustomerController doesn't require anything to
/// be initialized we can conform it to EmptyInitializable.
///
/// This will allow it to be passed by type.
extension CustomerController: EmptyInitializable { }
