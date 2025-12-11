db.orders.insertMany([{
        user_id: "user_id_juan_placeholder",
        order_date: new Date("2024-05-01"),
        status: "delivered",
        items: [{ product: "Polera Oversize Estampada", qty: 2, unit_price: 15990 }],
        total: 31980,
        payment_method: "tarjeta_credito",
        shipping_address: "Av. Concha y Toro 123",
        tracking_code: "CHILEXPRESS-001"
    },
    {
        user_id: "user_id_maria_placeholder",
        order_date: new Date("2024-05-02"),
        status: "processing",
        items: [{ product: "Jockey Tipo Trucker", qty: 2, unit_price: 9990 }],
        total: 19980,
        payment_method: "redcompra",
        shipping_address: "Calle Valparaíso 505",
        tracking_code: "STARKEN-002"
    },
    {
        user_id: "user_id_carlos_placeholder",
        order_date: new Date("2024-05-03"),
        status: "shipped",
        items: [{ product: "Jeans Mom Fit Tiro Alto", qty: 1, unit_price: 32990 }],
        total: 32990,
        payment_method: "transferencia_bancaria",
        shipping_address: "Paicaví 45",
        tracking_code: "BLUE-003"
    },
    {
        user_id: "user_id_pedro_placeholder",
        order_date: new Date("2024-05-04"),
        status: "cancelled",
        items: [{ product: "Mochila Apañadora Canvas", qty: 1, unit_price: 22990 }],
        total: 22990,
        payment_method: "tarjeta_credito",
        shipping_address: "Gran Avenida 8900",
        tracking_code: null
    },
    {
        user_id: "user_id_lucia_placeholder",
        order_date: new Date("2024-05-05"),
        status: "delivered",
        items: [
            { product: "Zapatillas Urbanas Chunky", qty: 1, unit_price: 45990 },
            { product: "Jockey Tipo Trucker", qty: 1, unit_price: 9990 }
        ],
        total: 55980,
        payment_method: "tarjeta_credito",
        shipping_address: "Pajaritos 3000",
        tracking_code: "CHILEXPRESS-005"
    },
    {
        user_id: "user_id_diego_placeholder",
        order_date: new Date("2024-05-06"),
        status: "pending",
        items: [{ product: "Parka Puffer Térmica", qty: 1, unit_price: 59990 }],
        total: 59990,
        payment_method: "mach",
        shipping_address: "Av. Alemania 550",
        tracking_code: "CORREOS-006"
    }
]);