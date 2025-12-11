db.employees.insertMany([{
        first_name: "Elena",
        last_name: "Vargas",
        position: "Jefa de Tienda",
        department: "Administración",
        salary: 1800000,
        hire_date: new Date("2020-01-10"),
        email: "elena.vargas@vivatrend.cl",
        is_manager: true
    },
    {
        first_name: "Miguel",
        last_name: "Herrera",
        position: "Vendedor Full Time",
        department: "Ventas",
        salary: 550000,
        hire_date: new Date("2022-03-15"),
        email: "miguel.herrera@vivatrend.cl",
        is_manager: false
    },
    {
        first_name: "Patricia",
        last_name: "Castro",
        position: "Vendedora Part Time",
        department: "Ventas",
        salary: 350000,
        hire_date: new Date("2022-05-20"),
        email: "patricia.castro@vivatrend.cl",
        is_manager: false
    },
    {
        first_name: "Jorge",
        last_name: "Salinas",
        position: "Bodeguero",
        department: "Logística",
        salary: 650000,
        hire_date: new Date("2021-08-01"),
        email: "jorge.salinas@vivatrend.cl",
        is_manager: true
    },
    {
        first_name: "Camila",
        last_name: "Rojas",
        position: "Soporte Web",
        department: "TI",
        salary: 1200000,
        hire_date: new Date("2021-02-28"),
        email: "camila.rojas@vivatrend.cl",
        is_manager: false
    },
    {
        first_name: "Andres",
        last_name: "Montes",
        position: "Contador",
        department: "Finanzas",
        salary: 1500000,
        hire_date: new Date("2019-11-11"),
        email: "andres.montes@vivatrend.cl",
        is_manager: false
    }
]);