import Fluent
import Vapor

func routes(_ app: Application) throws {
    //CRUD
    
    //get (/planets)
    app.get("planets"){ req in
        Planet.query(on: req.db).all()
    }
    
    //get by id (/planets/id)
    app.get("planets",":planetId"){ req -> EventLoopFuture<Planet> in
        Planet.find(req.parameters.get("planetId"), on: req.db)
            .unwrap(or: Abort(.notFound))
    }
    //post (/planets)
    app.post("planets"){ req -> EventLoopFuture<Planet> in
        
        let planet = try req.content.decode(Planet.self)
        
        return planet.create(on: req.db).map{planet}
    }
    
    //put (/planets)
    app.put("planets"){ req -> EventLoopFuture<HTTPStatus> in
        
        let planet = try req.content.decode(Planet.self)
        
        return Planet.find(planet.id, on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap{
                $0.name = planet.name
                return $0.update(on: req.db).transform(to: .ok)
            }
    }
    
    //delete (/planets/id)
    app.delete("planets",":planetsId"){ req -> EventLoopFuture<HTTPStatus> in
        
        Planet.find(req.parameters.get("planetsId"), on: req.db)
            .unwrap(or: Abort(.notFound))
            .flatMap{
                $0.delete(on: req.db)
            }.transform(to: .ok)
        
    }
    
}
