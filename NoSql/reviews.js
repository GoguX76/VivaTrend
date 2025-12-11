db.reviews.insertMany([{
        product_name: "Polera Oversize Estampada",
        user_email: "juan.gonzalez@email.com",
        rating: 5,
        comment: "Está filete la polera, la tela es súper buena y no destiñe. 10/10.",
        date: new Date("2024-05-10"),
        helpful_votes: 10,
        verified_purchase: true,
        images: ["foto_polera.jpg"]
    },
    {
        product_name: "Jockey Tipo Trucker",
        user_email: "maria.munoz@email.com",
        rating: 4,
        comment: "Bacán el gorro, pero me quedó un poco grande. Igual apaña pal sol.",
        date: new Date("2024-05-12"),
        helpful_votes: 2,
        verified_purchase: true,
        images: []
    },
    {
        product_name: "Jeans Mom Fit Tiro Alto",
        user_email: "carlos.tapia@email.com",
        rating: 5,
        comment: "Le compré estos jeans a mi polola y le quedaron joya. Se ven de buena calidad.",
        date: new Date("2024-05-15"),
        helpful_votes: 5,
        verified_purchase: true,
        images: ["fit_check.jpg"]
    },
    {
        product_name: "Zapatillas Urbanas Chunky",
        user_email: "lucia.mendez@email.com",
        rating: 3,
        comment: "Son lindas pero pesan caleta, pa caminar mucho cansan.",
        date: new Date("2024-05-18"),
        helpful_votes: 0,
        verified_purchase: true,
        images: []
    },
    {
        product_name: "Parka Puffer Térmica",
        user_email: "diego.paredes@email.com",
        rating: 5,
        comment: "La parka es carne de perro, aguanta la lluvia y el frío de Temuco sin dramas.",
        date: new Date("2024-05-20"),
        helpful_votes: 8,
        verified_purchase: true,
        images: ["nieve.jpg"]
    },
    {
        product_name: "Mochila Apañadora Canvas",
        user_email: "pedro.soto@email.com",
        rating: 2,
        comment: "Fome la mochila, se me descoció un tirante a la semana. Mala volá.",
        date: new Date("2024-05-22"),
        helpful_votes: 1,
        verified_purchase: true,
        images: []
    }
]);