db.users.insertMany([{
        first_name: "Juan",
        last_name: "González",
        email: "juan.gonzalez@email.com",
        password: "hashed_password_123",
        address: { street: "Av. Concha y Toro 123", city: "Puente Alto", zip: "8150000" },
        phone: "+56911112222",
        roles: ["customer"],
        created_at: new Date()
    },
    {
        first_name: "Maria",
        last_name: "Muñoz",
        email: "maria.munoz@email.com",
        password: "hashed_password_456",
        address: { street: "Calle Valparaíso 505", city: "Viña del Mar", zip: "2520000" },
        phone: "+56933334444",
        roles: ["customer", "vip"],
        created_at: new Date()
    },
    {
        first_name: "Carlos",
        last_name: "Tapia",
        email: "carlos.tapia@email.com",
        password: "hashed_password_789",
        address: { street: "Paicaví 45", city: "Concepción", zip: "4030000" },
        phone: "+56955556666",
        roles: ["customer"],
        created_at: new Date()
    },
    {
        first_name: "Ana",
        last_name: "Rojas",
        email: "ana.rojas@vivatrend.cl",
        password: "hashed_password_000",
        address: { street: "Av. Providencia 1234", city: "Providencia", zip: "7500000" },
        phone: "+56977778888",
        roles: ["admin"],
        created_at: new Date()
    },
    {
        first_name: "Pedro",
        last_name: "Soto",
        email: "pedro.soto@email.com",
        password: "hashed_password_111",
        address: { street: "Gran Avenida 8900", city: "La Cisterna", zip: "7970000" },
        phone: "+56999990000",
        roles: ["customer"],
        created_at: new Date()
    },
    {
        first_name: "Lucia",
        last_name: "Mendez",
        email: "lucia.mendez@email.com",
        password: "hashed_password_222",
        address: { street: "Pajaritos 3000", city: "Maipú", zip: "9250000" },
        phone: "+56912341234",
        roles: ["customer"],
        created_at: new Date()
    },
    {
        first_name: "Diego",
        last_name: "Paredes",
        email: "diego.paredes@email.com",
        password: "hashed_password_333",
        address: { street: "Av. Alemania 550", city: "Temuco", zip: "4780000" },
        phone: "+56943214321",
        roles: ["customer"],
        created_at: new Date()
    }
]);