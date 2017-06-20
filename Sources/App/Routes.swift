import Vapor

final class Routes: RouteCollection {
    let view: ViewRenderer
    init(_ view: ViewRenderer) {
        self.view = view
    }
    
    func build(_ builder: RouteBuilder) throws {
        /// GET /
        builder.get { req in
            return try self.view.make("welcome")
        }
        /*
        builder.get("orders") { req in
            return try Order.all().makeJSON()
        }

        builder.get("test/orders") { req in
            guard let customer = try Customer.all().first else {
                throw Abort.badRequest
            }

            let order = Order(customerId: customer.id!, applicant: "someone", address: "somewhere")
            try order.save()
            return try order.makeJSON()
        }
        */

        /// GET /customer/...
//        builder.resource("customers", CustomerController())
    }
}
