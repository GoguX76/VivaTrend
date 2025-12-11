db.products.insertMany([
  {
    name: "Polera Oversize Estampada",
    category: "Poleras",
    brand: "VivaTrend Originals",
    price: 15990,
    stock: 50,
    specs: { talla: "L", color: "Negro", material: "Algodón Peruano", calce: "Oversize" },
    tags: ["urbano", "verano", "facha"],
    release_date: new Date("2024-01-15"),
    active: true
  },
  {
    name: "Jeans Mom Fit Tiro Alto",
    category: "Jeans",
    brand: "Viva Denim",
    price: 32990,
    stock: 25,
    specs: { talla: "38", color: "Azul Pre-lavado", tiro: "Alto", elasticidad: "Rígido" },
    tags: ["clásico", "mujer", "apañador"],
    release_date: new Date("2023-11-20"),
    active: true
  },
  {
    name: "Zapatillas Urbanas Chunky",
    category: "Calzado",
    brand: "UrbanWalk",
    price: 45990,
    stock: 40,
    specs: { talla: "40", material_ext: "Eco Cuero", tipo_suela: "Plataforma" },
    tags: ["zapatillas", "tillas", "comodas"],
    release_date: new Date("2024-02-10"),
    active: true
  },
  {
    name: "Jockey Tipo Trucker",
    category: "Accesorios",
    brand: "Viva Accessories",
    price: 9990,
    stock: 60,
    specs: { talla: "Ajustable", material: "Malla/Poliéster", visera: "Curva" },
    tags: ["accesorios", "sol", "piola"],
    release_date: new Date("2024-03-05"),
    active: true
  },
  {
    name: "Parka Puffer Térmica",
    category: "Abrigos",
    brand: "NordicStyle",
    price: 59990,
    stock: 15,
    specs: { talla: "M", impermeabilidad: "Full", relleno: "Sintético", gorro: "Desmontable" },
    tags: ["invierno", "frio", "abrigo"],
    release_date: new Date("2024-04-01"),
    active: true
  },
  {
    name: "Polerón Canguro Básico",
    category: "Polerones",
    brand: "StreetWear CL",
    price: 24990,
    stock: 35,
    specs: { talla: "XL", material: "Franela", gorro: true, bolsillo: "Canguro" },
    tags: ["invierno", "básico", "relajo"],
    release_date: new Date("2024-03-20"),
    active: true
  },
  {
    name: "Mochila Apañadora Canvas",
    category: "Accesorios",
    brand: "StreetPack",
    price: 22990,
    stock: 20,
    specs: { capacidad: "20L", porta_notebook: true, material: "Lona dura" },
    tags: ["u", "colegio", "mochila"],
    release_date: new Date("2023-10-15"),
    active: true
  }
]);