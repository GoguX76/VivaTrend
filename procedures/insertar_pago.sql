BEGIN
    registrar_pago(
        12345678,
        987654321,
        2,
        50000,
        TO_DATE('18-09-2025', 'DD-MM-YYYY')
    );
END;