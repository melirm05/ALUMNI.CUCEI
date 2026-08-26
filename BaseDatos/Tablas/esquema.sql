DROP TABLE IF EXISTS pago, reservacion_habitacion, reservacion,
                     habitacion, tipo_habitacion, empleado, cliente CASCADE;

CREATE TABLE cliente (
    id_cliente     SERIAL PRIMARY KEY,
    documento      VARCHAR(20)  NOT NULL UNIQUE,
    nombre         VARCHAR(60)  NOT NULL,
    apellidos      VARCHAR(80)  NOT NULL,
    correo         VARCHAR(120) NOT NULL UNIQUE,
    telefono       VARCHAR(20),
    fecha_registro DATE         NOT NULL DEFAULT CURRENT_DATE
);

CREATE TABLE empleado (
    id_empleado SERIAL PRIMARY KEY,
    nombre      VARCHAR(60)  NOT NULL,
    apellidos   VARCHAR(80)  NOT NULL,
    puesto      VARCHAR(40)  NOT NULL,
    correo      VARCHAR(120) NOT NULL UNIQUE
);

CREATE TABLE tipo_habitacion (
    id_tipo      SERIAL        PRIMARY KEY,
    nombre       VARCHAR(40)   NOT NULL UNIQUE,
    descripcion  VARCHAR(200),
    capacidad    SMALLINT      NOT NULL CHECK (capacidad > 0),
    precio_noche NUMERIC(10,2) NOT NULL CHECK (precio_noche > 0)
);

CREATE TABLE habitacion (
    id_habitacion SERIAL      PRIMARY KEY,
    numero        VARCHAR(10) NOT NULL UNIQUE,
    id_tipo       INTEGER     NOT NULL REFERENCES tipo_habitacion(id_tipo),
    piso          SMALLINT    NOT NULL CHECK (piso > 0),
    estado        VARCHAR(15) NOT NULL DEFAULT 'operativa'
                  CHECK (estado IN ('operativa', 'mantenimiento', 'baja'))
);

CREATE TABLE reservacion (
    id_reservacion    SERIAL      PRIMARY KEY,
    id_cliente        INTEGER     NOT NULL REFERENCES cliente(id_cliente),
    id_empleado       INTEGER     NOT NULL REFERENCES empleado(id_empleado),
    fecha_reservacion DATE        NOT NULL DEFAULT CURRENT_DATE,
    fecha_entrada     DATE        NOT NULL,
    fecha_salida      DATE        NOT NULL,
    estado            VARCHAR(12) NOT NULL DEFAULT 'pendiente'
                      CHECK (estado IN ('pendiente', 'confirmada', 'en_curso',
                                        'finalizada', 'cancelada')),
    CONSTRAINT ck_reservacion_fechas CHECK (fecha_salida > fecha_entrada)
);

CREATE TABLE reservacion_habitacion (
    id_reservacion INTEGER       NOT NULL
                   REFERENCES reservacion(id_reservacion) ON DELETE CASCADE,
    id_habitacion  INTEGER       NOT NULL
                   REFERENCES habitacion(id_habitacion),
    precio_noche   NUMERIC(10,2) NOT NULL CHECK (precio_noche > 0),
    PRIMARY KEY (id_reservacion, id_habitacion)
);

CREATE TABLE pago (
    id_pago        SERIAL        PRIMARY KEY,
    id_reservacion INTEGER       NOT NULL REFERENCES reservacion(id_reservacion),
    monto          NUMERIC(10,2) NOT NULL CHECK (monto > 0),
    fecha_pago     DATE          NOT NULL DEFAULT CURRENT_DATE,
    metodo         VARCHAR(15)   NOT NULL
                   CHECK (metodo IN ('efectivo', 'tarjeta', 'transferencia'))
);

CREATE INDEX idx_reservacion_fechas   ON reservacion (fecha_entrada, fecha_salida);
CREATE INDEX idx_reshab_habitacion    ON reservacion_habitacion (id_habitacion);

INSERT INTO tipo_habitacion (nombre, descripcion, capacidad, precio_noche) VALUES
 ('Sencilla', 'Una cama matrimonial, bano privado, wifi',              2, 850.00),
 ('Doble',    'Dos camas matrimoniales, bano privado, wifi, escritorio', 4, 1400.00),
 ('Suite',    'Sala independiente, jacuzzi, terraza, wifi',            4, 2600.00),
 ('Familiar', 'Tres camas, cocineta, bano y medio',                     6, 2100.00);

INSERT INTO empleado (nombre, apellidos, puesto, correo) VALUES
 ('Melanye',  'Ramos Munoz',    'Recepcion', 'melanye.ramos@roomly.mx'),
 ('Alicia',   'Perez Gomez',    'Recepcion', 'alicia.perez@roomly.mx'),
 ('Leonardo', 'Martinez Glz.',  'Gerencia',  'leonardo.martinez@roomly.mx');

INSERT INTO habitacion (numero, id_tipo, piso, estado) VALUES
 ('101', 1, 1, 'operativa'),
 ('102', 1, 1, 'operativa'),
 ('103', 2, 1, 'operativa'),
 ('201', 2, 2, 'operativa'),
 ('202', 2, 2, 'mantenimiento'),
 ('203', 4, 2, 'operativa'),
 ('301', 3, 3, 'operativa'),
 ('302', 3, 3, 'operativa');

INSERT INTO cliente (documento, nombre, apellidos, correo, telefono) VALUES
 ('IJUC900312HJC', 'Jesus Armando', 'Juarez Cabrera', 'jesus.juarez@correo.mx',  '3312345678'),
 ('RAMU880725MJC', 'Sofia',         'Ramirez Duenas', 'sofia.ramirez@correo.mx', '3318765432'),
 ('LOTO950101HJC', 'Miguel',        'Lopez Torres',   'miguel.lopez@correo.mx',  '3311223344'),
 ('GARC920617MJC', 'Ana Karen',     'Garcia Cortes',  'ana.garcia@correo.mx',    '3315556677'),
 ('HEMO870204HJC', 'Ricardo',       'Hernandez Mora', 'ricardo.mora@correo.mx',  '3319998877');

INSERT INTO reservacion (id_cliente, id_empleado, fecha_reservacion, fecha_entrada, fecha_salida, estado)
VALUES (1, 1, '2026-08-20', '2026-09-03', '2026-09-07', 'confirmada');
INSERT INTO reservacion_habitacion VALUES (1, 1, 850.00);

INSERT INTO reservacion (id_cliente, id_empleado, fecha_reservacion, fecha_entrada, fecha_salida, estado)
VALUES (2, 1, '2026-08-21', '2026-09-05', '2026-09-09', 'confirmada');
INSERT INTO reservacion_habitacion VALUES (2, 4, 1400.00),
                                          (2, 6, 2100.00);

INSERT INTO reservacion (id_cliente, id_empleado, fecha_reservacion, fecha_entrada, fecha_salida, estado)
VALUES (3, 2, '2026-08-18', '2026-09-04', '2026-09-06', 'cancelada');
INSERT INTO reservacion_habitacion VALUES (3, 2, 850.00);

INSERT INTO reservacion (id_cliente, id_empleado, fecha_reservacion, fecha_entrada, fecha_salida, estado)
VALUES (4, 2, '2026-08-22', '2026-09-10', '2026-09-13', 'pendiente');
INSERT INTO reservacion_habitacion VALUES (4, 7, 2200.00);

INSERT INTO reservacion (id_cliente, id_empleado, fecha_reservacion, fecha_entrada, fecha_salida, estado)
VALUES (5, 3, '2026-08-01', '2026-08-10', '2026-08-14', 'finalizada');
INSERT INTO reservacion_habitacion VALUES (5, 3, 1400.00);

INSERT INTO pago (id_reservacion, monto, fecha_pago, metodo) VALUES
 (1, 1700.00, '2026-08-20', 'tarjeta'),
 (2, 3500.00, '2026-08-21', 'transferencia'),
 (2, 10500.00,'2026-08-24', 'transferencia'),
 (5, 5600.00, '2026-08-14', 'efectivo');

SELECT h.numero,
       t.nombre        AS tipo,
       t.capacidad,
       t.precio_noche
FROM   habitacion h
JOIN   tipo_habitacion t ON t.id_tipo = h.id_tipo
WHERE  h.estado = 'operativa'
  AND  NOT EXISTS (
           SELECT 1
           FROM   reservacion_habitacion rh
           JOIN   reservacion r ON r.id_reservacion = rh.id_reservacion
           WHERE  rh.id_habitacion = h.id_habitacion
             AND  r.estado <> 'cancelada'
             AND  r.fecha_entrada < DATE '2026-09-07'
             AND  r.fecha_salida  > DATE '2026-09-03'
       )
ORDER BY t.precio_noche, h.numero;

SELECT r.id_reservacion,
       c.nombre || ' ' || c.apellidos          AS cliente,
       r.fecha_entrada,
       r.fecha_salida,
       (r.fecha_salida - r.fecha_entrada)      AS noches,
       COUNT(rh.id_habitacion)                 AS habitaciones,
       SUM(rh.precio_noche) * (r.fecha_salida - r.fecha_entrada) AS total
FROM   reservacion r
JOIN   cliente c                ON c.id_cliente = r.id_cliente
JOIN   reservacion_habitacion rh ON rh.id_reservacion = r.id_reservacion
WHERE  r.estado <> 'cancelada'
GROUP  BY r.id_reservacion, c.nombre, c.apellidos, r.fecha_entrada, r.fecha_salida
ORDER  BY r.id_reservacion;

SELECT r.id_reservacion,
       c.apellidos,
       SUM(rh.precio_noche) * (r.fecha_salida - r.fecha_entrada)      AS total,
       COALESCE((SELECT SUM(p.monto) FROM pago p
                 WHERE p.id_reservacion = r.id_reservacion), 0)       AS pagado,
       SUM(rh.precio_noche) * (r.fecha_salida - r.fecha_entrada)
         - COALESCE((SELECT SUM(p.monto) FROM pago p
                     WHERE p.id_reservacion = r.id_reservacion), 0)   AS saldo
FROM   reservacion r
JOIN   cliente c                 ON c.id_cliente = r.id_cliente
JOIN   reservacion_habitacion rh ON rh.id_reservacion = r.id_reservacion
WHERE  r.estado <> 'cancelada'
GROUP  BY r.id_reservacion, c.apellidos, r.fecha_entrada, r.fecha_salida
ORDER  BY saldo DESC;

SELECT t.nombre                    AS tipo,
       COUNT(*)                    AS veces_reservada
FROM   reservacion_habitacion rh
JOIN   habitacion h       ON h.id_habitacion = rh.id_habitacion
JOIN   tipo_habitacion t  ON t.id_tipo = h.id_tipo
JOIN   reservacion r      ON r.id_reservacion = rh.id_reservacion
WHERE  r.estado <> 'cancelada'
GROUP  BY t.nombre
ORDER  BY veces_reservada DESC;

SELECT c.documento,
       c.nombre || ' ' || c.apellidos AS cliente,
       COUNT(r.id_reservacion)        AS reservaciones,
       MAX(r.fecha_salida)            AS ultima_estancia
FROM   cliente c
LEFT   JOIN reservacion r ON r.id_cliente = c.id_cliente
                         AND r.estado <> 'cancelada'
GROUP  BY c.id_cliente, c.documento, c.nombre, c.apellidos
ORDER  BY reservaciones DESC;
