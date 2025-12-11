db.support_tickets.insertMany([{
        user_email: "juan.gonzalez@email.com",
        subject: "Atraso en el envío",
        description: "Cabros, compré hace una semana y todavía no llega la cuestión. Qué onda?",
        status: "open",
        priority: "high",
        created_at: new Date(),
        assigned_to: "Camila Rojas",
        messages: [{ sender: "user", text: "¿Falta mucho pa que llegue?" }]
    },
    {
        user_email: "maria.munoz@email.com",
        subject: "Cambio de Talla",
        description: "El gorro me baila, necesito cambiarlo por uno más chico o que me devuelvan las lucas.",
        status: "closed",
        priority: "medium",
        created_at: new Date("2024-04-10"),
        assigned_to: "Miguel Herrera",
        messages: [{ sender: "user", text: "Me queda gigante" }, { sender: "agent", text: "Hola María, gestionaremos el cambio a la brevedad." }]
    },
    {
        user_email: "carlos.tapia@email.com",
        subject: "Falla en Jeans",
        description: "El cierre venía malo, se traba. Pésimo ahí.",
        status: "in_progress",
        priority: "high",
        created_at: new Date(),
        assigned_to: "Camila Rojas",
        messages: [{ sender: "user", text: "Mando foto pa que cachen" }]
    },
    {
        user_email: "lucia.mendez@email.com",
        subject: "Consulta Stock",
        description: "Hola, ¿cuándo les llegan más zapatillas talla 37? Las quiero sí o sí.",
        status: "resolved",
        priority: "low",
        created_at: new Date("2024-01-01"),
        assigned_to: "Patricia Castro",
        messages: []
    },
    {
        user_email: "diego.paredes@email.com",
        subject: "Dirección incorrecta",
        description: "Puse mal el número de la casa, es 550 no 500. Arréglenlo porfa antes que salga.",
        status: "open",
        priority: "medium",
        created_at: new Date(),
        assigned_to: "Jorge Salinas",
        messages: [{ sender: "user", text: "Me equivoqué en la dirección" }]
    },
    {
        user_email: "pedro.soto@email.com",
        subject: "Cobro duplicado en la tarjeta",
        description: "Me descontaron dos veces la compra de la mochila. Necesito que reversen una.",
        status: "escalated",
        priority: "critical",
        created_at: new Date(),
        assigned_to: "Andres Montes",
        messages: [{ sender: "user", text: "Devuelvan la plata al tiro porfa" }]
    }
]);