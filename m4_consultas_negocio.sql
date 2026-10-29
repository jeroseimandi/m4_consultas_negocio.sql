-- Consulta 1: Resumen ejecutivo mensual
SELECT 
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta);

-- Consulta 2: Ranking de productos (Top 5)
SELECT TOP 5
    p.id_producto,
    p.nombre_producto,
    SUM(v.cantidad) AS unidades_vendidas,
    SUM(v.cantidad * v.precio_unitario) AS total_generado
FROM ventas v
INNER JOIN productos p ON v.id_producto = p.id_producto
GROUP BY p.id_producto, p.nombre_producto
ORDER BY total_generado DESC;

-- Consulta 3: Clientes recurrentes
SELECT 
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1;

-- Consulta 4: Productos por encima/por debajo del promedio
WITH ventas_por_producto AS (
    SELECT 
        v.id_producto,
        p.nombre_producto,
        SUM(v.cantidad * v.precio_unitario) AS total_facturado
    FROM ventas v
    INNER JOIN productos p ON v.id_producto = p.id_producto
    GROUP BY v.id_producto, p.nombre_producto
),
promedio_general AS (
    SELECT AVG(total_facturado) AS promedio_facturacion
    FROM ventas_por_producto
)
SELECT 
    v.id_producto,
    v.nombre_producto,
    v.total_facturado,
    CASE 
        WHEN v.total_facturado >= p.promedio_facturacion THEN 'Por encima'
        ELSE 'Por debajo'
    END AS clasificacion_promedio
FROM ventas_por_producto v
CROSS JOIN promedio_general p
ORDER BY v.total_facturado DESC;

/* =====================================================
HALLAZGOS DE NEGOCIO:
1. El producto 103 (Notebook) concentra la mayor parte de la facturación total debido a su alto valor unitario.
2. El cliente con id_cliente = 1 es el único cliente recurrente hasta el momento, habiendo registrado 2 pedidos.
3. Más de la mitad de los productos vendidos se encuentran por debajo del promedio de facturación general.
===================================================== */
