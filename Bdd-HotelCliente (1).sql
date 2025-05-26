CREATE DATABASE IF NOT EXISTS Trivago;
USE Trivago;
show tables;
-- ======================== TABLAS ==========================

-- Tabla: estados ===========================================
CREATE TABLE IF NOT EXISTS estados (
    id_estado INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    estado VARCHAR(50) UNIQUE,
    abreviatura VARCHAR(5) UNIQUE
);

-- Tabla: Clientes ==========================================
CREATE TABLE Clientes (
    id_cliente INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    CURP VARCHAR(18) UNIQUE,
    nombre VARCHAR(50) NOT NULL,
    ap_paterno VARCHAR(50) NOT NULL,
    ap_materno VARCHAR(50),
    fecha_nacimiento DATE NOT NULL,
    nacionalidad VARCHAR(45) NOT NULL,
    email VARCHAR(255) unique,
    telefono VARCHAR(20) NOT NULL,
    calle_numero VARCHAR(100),
    colonia VARCHAR(50),
    codigo_postal VARCHAR(10),
    ciudad VARCHAR(50),
    id_estado INT,
    pais CHAR(2) NOT NULL,
    FOREIGN KEY (id_estado) REFERENCES estados(id_estado)
);

-- Trigger: Asignar nacionalidad 'Mexicana' si está vacía
DELIMITER $$
CREATE TRIGGER BEF_INSERT_Clientes_BEFORE_INSERT
BEFORE INSERT ON Clientes
FOR EACH ROW
BEGIN
    IF NEW.nacionalidad IS NULL OR NEW.nacionalidad = '' THEN
        SET NEW.nacionalidad = 'Mexicana';
    END IF;
END $$
DELIMITER ;

-- Tabla: Servicios ==========================================
CREATE TABLE IF NOT EXISTS servicios (
    id_servicios INT NOT NULL AUTO_INCREMENT,
    nombre_servicio ENUM('desayuno', 'transporte', 'lavandería', 'spa') NOT NULL,
    descripcion VARCHAR(100),
    costo DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (id_servicios)
);

-- Tabla: hoteles ============================================
CREATE TABLE IF NOT EXISTS hoteles(
id_hotel INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
nombre VARCHAR(60) NOT NULL UNIQUE,
categoria ENUM('una estrella', 'dos estrellas', 'tres estrellas', 'cuatro estrellas', 'cinco estrellas') NOT NULL DEFAULT 'cinco estrellas', 
calle VARCHAR(100),
num_ext VARCHAR(10), 
colonia VARCHAR(50), 
codigo_postal VARCHAR(10), 
ciudad VARCHAR(60),
id_estado INT NOT NULL,
telefono VARCHAR(15),
FOREIGN KEY (id_estado) REFERENCES estados(id_estado)
);
-- Tabla: hoteles_servicios ==================================
CREATE TABLE IF NOT EXISTS hoteles_servicios (
    id_hotel INT NOT NULL,
    id_servicios INT NOT NULL,
    PRIMARY KEY (id_hotel, id_servicios),
    CONSTRAINT `fk_Hoteles_has_servicios_Hoteles1`
        FOREIGN KEY (id_hotel)
        REFERENCES hoteles (id_hotel)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT `fk_Hoteles_has_servicios_servicios1`
        FOREIGN KEY (id_servicios)
        REFERENCES servicios (id_servicios)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);
-- Triggers servicios 
DELIMITER $$
CREATE TRIGGER bef_insert_servicio
BEFORE INSERT ON servicios
FOR EACH ROW
BEGIN
    IF NEW.descripcion IS NULL OR TRIM(NEW.descripcion) = '' THEN
        SET NEW.descripcion = 'Servicio sin descripción';
    END IF;
END $$
CREATE TRIGGER bef_insert_hotel_servicio
BEFORE INSERT ON hoteles_servicios
FOR EACH ROW
BEGIN
    IF NEW.id_servicios <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El ID del servicio debe ser mayor que cero';
    END IF;
END $$
DELIMITER ;
-- Tabla: Pagos ===============================================

CREATE TABLE IF NOT EXISTS Pagos (
    id_pago INT NOT NULL AUTO_INCREMENT,
    fecha_pago DATETIME NOT NULL,
    monto_pago DECIMAL(10,2) NOT NULL,
    metodo_pago ENUM('efectivo', 'tarjeta', 'transferencia') NOT NULL,
    comprobante VARCHAR(100) NULL,
    PRIMARY KEY (id_pago)
) ;

-- Trigger: Before insert (se asegura que no agregue una fecha de pago del futuro)
DELIMITER $$
CREATE TRIGGER before_insert_pago_fecha
BEFORE INSERT ON Pagos
FOR EACH ROW
BEGIN
    IF NEW.fecha_pago > NOW() THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La fecha del pago no puede ser futura.';
    END IF;
END $$
DELIMITER ;

-- Trigger: BEFORE INSERT (validación)
DELIMITER $$
CREATE TRIGGER before_insert_pago_check
BEFORE INSERT ON Pagos
FOR EACH ROW
BEGIN
    IF NEW.monto_pago <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El monto del pago debe ser mayor a 0';
    END IF;
END $$
DELIMITER ;

-- Tabla: Clientes_servicios =====================================
CREATE TABLE Clientes_servicios (
    id_cliente INT NOT NULL,
    id_servicios INT NOT NULL,
    id_pago INT NOT NULL,
    PRIMARY KEY (id_cliente, id_servicios, id_pago),
    FOREIGN KEY (id_cliente) REFERENCES Clientes(id_cliente),
    FOREIGN KEY (id_servicios) REFERENCES servicios(id_servicios),
    FOREIGN KEY (id_pago) REFERENCES Pagos(id_pago)
);

-- Tabla: promociones =============================================
CREATE TABLE IF NOT EXISTS promociones (
    id_promocion INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion VARCHAR(120) NOT NULL,
    descuento DECIMAL(3,2) NOT NULL,
    fecha_inicio DATETIME NOT NULL,
    fecha_fin DATETIME NOT NULL
);

-- Tabla: hoteles_promociones =====================================
CREATE TABLE IF NOT EXISTS hoteles_promociones (
    id_hotel INT NOT NULL,
    id_promocion INT NOT NULL,
    PRIMARY KEY (id_hotel, id_promocion),
    FOREIGN KEY (id_hotel) REFERENCES hoteles(id_hotel),
    FOREIGN KEY (id_promocion) REFERENCES promociones(id_promocion)
);

-- Tabla: tipos_habitacion ========================================

CREATE TABLE if not exists tipos_habitacion (
    id_tipo INT AUTO_INCREMENT PRIMARY KEY,
    nombre_tipo VARCHAR(50) NOT NULL UNIQUE,
    descripcion TEXT
);

-- Tabla: habitaciones  ===========================================
CREATE TABLE IF NOT EXISTS habitaciones (
    num_habitacion INT NOT NULL UNIQUE PRIMARY KEY,
    costo DECIMAL(7,2) NOT NULL,
    num_max_huesp INT NOT NULL, 
    estatus ENUM('Disponible', 'Ocupada', 'En mantenimiento') NOT NULL,
    piso INT,
    id_hotel INT NOT NULL,
    id_tipo INT NOT NULL,
    FOREIGN KEY (id_hotel) REFERENCES hoteles(id_hotel),
    FOREIGN KEY (id_tipo) REFERENCES tipos_habitacion(id_tipo)
);

-- Tabla: empleados
CREATE TABLE IF NOT EXISTS empleados (
    id_empleados INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    ap_paterno VARCHAR(50) NOT NULL,
    ap_materno VARCHAR(50),
    puesto ENUM('gerente', 'cocinero', 'limpieza', 'seguridad', 'recepcionista', 'miselaneo') NOT NULL,
    horario ENUM('Mañana', 'Tarde', 'Noche') NOT NULL,
    fecha_contratacion DATE NOT NULL,
    salario_mensual DECIMAL(10, 2) NOT NULL,
    id_hotel INT NOT NULL,
    FOREIGN KEY (id_hotel) REFERENCES hoteles(id_hotel)
);

DELIMITER $$
CREATE TRIGGER BI_valid_salario
BEFORE INSERT ON empleados
FOR EACH ROW
BEGIN
    IF NEW.salario_mensual <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El salario debe ser mayor a 0.';
    END IF;
END $$
DELIMITER ;

-- Tabla reservaciones =======================================
CREATE TABLE reservaciones (
    id_reservacion INT PRIMARY KEY AUTO_INCREMENT,
    fecha_entrada DATETIME NOT NULL,
    fecha_salida DATETIME NOT NULL,
    numero_huespedes INT NOT NULL,
    estatus ENUM('Confirmada', 'Cancelada', 'Finalizada') NOT NULL,
    monto DECIMAL(10,2) NOT NULL,
    id_cliente INT NOT NULL,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    INDEX (fecha_entrada)
);

-- Tabla: Reservaciones_habitaciones
CREATE TABLE reservaciones_habitacion (
    id_reservacion INT NOT NULL,
    num_habitacion INT NOT NULL,
    id_pago INT NOT NULL,
    PRIMARY KEY (id_reservacion, num_habitacion),
    FOREIGN KEY (id_reservacion) REFERENCES reservaciones(id_reservacion),
    FOREIGN KEY (num_habitacion) REFERENCES habitaciones(num_habitacion),
    FOREIGN KEY (id_pago) REFERENCES pagos(id_pago)
);

-- Tabla: historial_reservacion
CREATE TABLE IF NOT EXISTS historial_reservacion (
    id_historial INT AUTO_INCREMENT PRIMARY KEY,
    id_reservacion INT NOT NULL,
    fecha_entrada DATE NOT NULL,
    fecha_salida DATE NOT NULL,
    accion ENUM('INSERT', 'UPDATE', 'DELETE') NOT NULL,
    fecha_modificacion DATETIME NOT NULL,
    usuario_modifico VARCHAR(100) NOT NULL
);

DELIMITER $$
CREATE TRIGGER after_insert_reservacion
AFTER INSERT ON reservaciones
FOR EACH ROW
BEGIN
    INSERT INTO historial_reservacion (
        id_reservacion, fecha_entrada, fecha_salida, 
        accion, fecha_modificacion, usuario_modifico
    ) VALUES (
        NEW.id_reservacion, NEW.fecha_entrada, NEW.fecha_salida,
        'INSERT', NOW(), USER()
    );
END $$

CREATE TRIGGER after_update_reservacion
AFTER UPDATE ON reservaciones
FOR EACH ROW
BEGIN
    INSERT INTO historial_reservacion (
        id_reservacion, fecha_entrada, fecha_salida, 
        accion, fecha_modificacion, usuario_modifico
    ) VALUES (
        NEW.id_reservacion, NEW.fecha_entrada, NEW.fecha_salida,
        'UPDATE', NOW(), USER()
    );
END $$
DELIMITER ;

-- Tabla: bitacora_acciones
CREATE TABLE IF NOT EXISTS bitacora_acciones (
    id_bitacora INT AUTO_INCREMENT PRIMARY KEY,
    tabla_afectada VARCHAR(50) NOT NULL,
    id_registro INT NOT NULL,
    accion VARCHAR(50) NOT NULL,
    descripcion TEXT,
    fecha_accion DATETIME NOT NULL,
    usuario_accion VARCHAR(100) NOT NULL,
    id_estado INT
);

-- creacion de bitacora dice en nuestra bitacora por cada monto de pago, se hace despues de cada pago indicando fecha hora monto -- 
DELIMITER $$
CREATE TRIGGER after_insert_cliente
AFTER INSERT ON Clientes
FOR EACH ROW
BEGIN
    DECLARE estado_id INT;
    SET estado_id = COALESCE(NEW.id_estado, 1); -- Valor predeterminado si id_estado es nulo
    
    INSERT INTO bitacora_acciones (
        tabla_afectada, id_registro, accion, descripcion, 
        fecha_accion, usuario_accion, id_estado
    ) VALUES (
        'Clientes', NEW.id_cliente, 'INSERT', 
        CONCAT('Nuevo cliente: ', NEW.nombre, ' ', NEW.ap_paterno),
        NOW(), USER(), estado_id
    );
END $$

CREATE TRIGGER after_insert_pago
AFTER INSERT ON Pagos
FOR EACH ROW
BEGIN
    DECLARE cliente_id INT;
    DECLARE servicio_nombre VARCHAR(50);
    DECLARE estado_id INT;
    
    -- Intentar obtener cliente_id, servicio_nombre y id_estado
    SELECT cs.id_cliente, s.nombre_servicio, c.id_estado
    INTO cliente_id, servicio_nombre, estado_id
    FROM Clientes_servicios cs
    JOIN servicios s ON cs.id_servicios = s.id_servicios
    LEFT JOIN Clientes c ON cs.id_cliente = c.id_cliente
    WHERE cs.id_pago = NEW.id_pago
    LIMIT 1;
    
    -- Manejar caso donde no hay registro en Clientes_servicios
    IF cliente_id IS NULL THEN
        SET cliente_id = 0;
        SET servicio_nombre = 'servicio no especificado';
        SET estado_id = 1; -- Valor predeterminado para id_estado
    END IF;
    
    -- Insertar en bitacora_acciones
    INSERT INTO bitacora_acciones (
        tabla_afectada, id_registro, accion, descripcion, 
        fecha_accion, usuario_accion, id_estado
    ) VALUES (
        'Pagos', NEW.id_pago, 'INSERT', 
        CONCAT('Cliente ID ', cliente_id, 
               ' pagó $', NEW.monto_pago, ' por ', 
               servicio_nombre, ' mediante ', NEW.metodo_pago),
        NOW(), USER(), estado_id
    );
END $$
DELIMITER ;

show tables;
-- ======================== INSERTS ==========================
-- Insert de estados 
INSERT INTO estados (estado, abreviatura) VALUES
('Aguascalientes', 'AGS'),
('Baja California', 'BC'),
('Baja California Sur', 'BCS'),
('Campeche', 'CAMP'),
('Coahuila', 'COAH'),
('Colima', 'COL'),
('Chiapas', 'CHIS'),
('Chihuahua', 'CHIH'),
('Ciudad de México', 'CDMX'),
('Durango', 'DGO'),
('Guanajuato', 'GTO'),
('Guerrero', 'GRO'),
('Hidalgo', 'HGO'),
('Jalisco', 'JAL'),
('Estado de México', 'MEX'),
('Michoacán', 'MICH'),
('Morelos', 'MOR'),
('Nayarit', 'NAY'),
('Nuevo León', 'NL'),
('Oaxaca', 'OAX'),
('Puebla', 'PUE'),
('Querétaro', 'QRO'),
('Quintana Roo', 'QR'),
('San Luis Potosí', 'SLP'),
('Sinaloa', 'SIN'),
('Sonora', 'SON'),
('Tabasco', 'TAB'),
('Tamaulipas', 'TAMP'),
('Tlaxcala', 'TLAX'),
('Veracruz', 'VER'),
('Yucatán', 'YUC'),
('Zacatecas', 'ZAC');

-- Insertar Clientes
INSERT INTO Clientes (
    CURP, nombre, ap_paterno, ap_materno, fecha_nacimiento, nacionalidad,
    email, telefono, calle_numero, colonia, codigo_postal,
    ciudad, id_estado, pais
)

VALUES
('GARC010101HDFRRNA1', 'Luis', 'García', 'Ramírez', '2001-01-01', 'Mexicana',
 'luis.garcia@email.com', '5551234567', 'Av. Reforma 123', 'Centro', '06000',
 'Ciudad de México', 1, 'MX'),
('LOPE020202MMNTRLA2', 'María', 'López', 'Martínez', '2002-02-02', NULL,
 'maria.lopez@email.com', '5549876543', 'Calle 5 #45', 'Nápoles', '03810',
 'Ciudad de México', 1, 'MX'),
('HERN030303HMCHNNA3', 'Juan', 'Hernández', 'Chávez', '2003-03-03', 'Mexicana',
 'juan.hernandez@email.com', '5536789123', 'Insurgentes Sur 800', 'Del Valle', '03100',
 'Ciudad de México', 1, 'MX'),
('RODR040404HGTZLRA4', 'Laura', 'Rodríguez', 'Zúñiga', '2004-04-04', '',
 'laura.rodriguez@email.com', '5523456789', 'Av. Juárez 10', 'Guerrero', '06300',
 'Ciudad de México', 1, 'MX'),
('FERN050505HMXMLLA5', 'Carlos', 'Fernández', 'Morales', '2005-05-05', 'Mexicana',
 'carlos.fernandez@email.com', '5512345678', 'Callejón del Triunfo 12', 'Tacuba', '11410',
 'Ciudad de México', 1, 'MX'),
('GOME060606HDFMNA6', 'Ana', 'Gómez', 'Nava', '2006-06-06', 'Mexicana', 
 'ana.gomez@email.com', '5512345679', 'Calle 15 #30', 'Polanco', '11560', 
 'Ciudad de México', 1, 'MX'),
('MART070707HDFRTA7', 'Pedro', 'Martínez', 'Reyes', '2007-07-07', NULL, 
 'pedro.martinez@email.com', '5512345680', 'Av. Insurgentes 200', 'Roma', '06700', 
 'Ciudad de México', 1, 'MX'),
('PERE080808HDFSRA8', 'Sofía', 'Pérez', 'Ríos', '2008-08-08', 'Mexicana', 
 'sofia.perez@email.com', '5512345681', 'Calle 20 #10', 'Condesa', '06140', 
 'Ciudad de México', 1, 'MX'),
('SANC090909HDFNCA9', 'Miguel', 'Sánchez', 'Cruz', '2009-09-09', '', 
 'miguel.sanchez@email.com', '5512345682', 'Av. Revolución 50', 'Tacubaya', '11870', 
 'Ciudad de México', 1, 'MX'),
('TORR101010HDFRRA0', 'Gabriela', 'Torres', 'Ramírez', '2010-10-10', 'Mexicana', 
 'gabriela.torres@email.com', '5512345683', 'Calle 25 #15', 'Santa Fe', '01376', 
 'Ciudad de México', 1, 'MX'),
('RUIZ111111HDFZMA1', 'Fernanda', 'Ruiz', 'Mendoza', '2011-11-11', NULL, 
 'fernanda.ruiz@email.com', '5512345684', 'Calle 30 #5', 'Lomas', '11000', 
 'Ciudad de México', 1, 'MX'),
('CAST121212HDFSTA2', 'Diego', 'Castillo', 'Soto', '2012-12-12', 'Mexicana', 
 'diego.castillo@email.com', '5512345685', 'Av. Chapultepec 100', 'Juárez', '06600', 
 'Ciudad de México', 1, 'MX'),
('MORA131313HDFRAA3', 'Valeria', 'Morales', 'Ramos', '2013-01-13', '', 
 'valeria.morales@email.com', '5512345686', 'Calle 35 #20', 'Coyoacán', '04300', 
 'Ciudad de México', 1, 'MX'),
('VARG141414HDFRGA4', 'Andrés', 'Vargas', 'Gómez', '2014-02-14', 'Mexicana', 
 'andres.vargas@email.com', '5512345687', 'Av. Universidad 300', 'Narvarte', '03020', 
 'Ciudad de México', 1, 'MX'),
('DELG151515HDFGLA5', 'Camila', 'Delgado', 'López', '2015-03-15', NULL, 
 'camila.delgado@email.com', '5512345688', 'Calle 40 #25', 'Álvaro Obregón', '01120', 
 'Ciudad de México', 1, 'MX');
 -- Insertar hoteles
INSERT INTO hoteles (nombre, calle, num_ext, colonia, codigo_postal, ciudad, id_estado, telefono)
VALUES 
('Hotel Sol del Valle', 'Av. Reforma', '123', 'Centro', '06000', 'Ciudad de México', 1, '555-123-4567'),
('Hotel Azul Marino', 'Calle 5 de Febrero', '45A', 'La Playa', '77500', 'Cancún', 2, '998-456-7890'),
('Hotel Sierra Alta', 'Av. Juárez', '789', 'Zona Norte', '31000', 'Chihuahua', 3, '614-987-6543'),
('Hotel Las Palmas', 'Calle Hidalgo', '10B', 'Centro Histórico', '83000', 'Hermosillo', 4, '662-321-0000'),
('Hotel Nube Blanca', 'Boulevard del Sol', '22', 'Residencial Primavera', '50000', 'Toluca', 5, '722-888-1122');

-- Insertar hoteles_servicios
INSERT INTO hoteles_servicios (id_hotel, id_servicios) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

-- Insertar registros de prueba para Pagos
INSERT INTO Pagos (fecha_pago, monto_pago, metodo_pago, comprobante) VALUES
('2024-05-01 14:30:00', 2500.00, 'tarjeta', 'COMP-001'),
('2024-05-02 10:15:00', 1800.50, 'efectivo', 'COMP-002'),
('2024-05-03 16:45:00', 3200.00, 'transferencia', 'COMP-003'),
('2024-05-04 12:00:00', 1500.75, 'tarjeta', 'COMP-004'),
('2024-05-05 09:20:00', 4100.00, 'efectivo', 'COMP-005');

-- Insertar en Clientes_servicios
INSERT INTO Clientes_servicios (id_cliente, id_servicios, id_pago)
VALUES
(1, 2, 3),
(2, 1, 2),
(3, 3, 4),
(4, 4, 1),
(5, 2, 5),
(6, 1, 1),
(7, 2, 2),
(8, 3, 3),
(9, 4, 4),
(10, 5, 5),
(11, 1, 1),
(12, 2, 2),
(13, 3, 3),
(14, 4, 4),
(15, 5, 5);

-- Insertar cliente para probar trigger de nacionalidad
INSERT INTO Clientes (
    CURP, nombre, ap_paterno, ap_materno, fecha_nacimiento,
    email, telefono, calle_numero, colonia, codigo_postal, ciudad, id_estado, pais
) VALUES (
    'LOPE800101HDFRRN09', 'Luis', 'López', 'Ramírez', '1980-01-01',
    'luis.lopez@gmail.com', '5512345678', 'Calle 10 #25', 'Centro', '01000', 'CDMX', 1, 'MX'
);

-- Insertar empleados
INSERT INTO empleados (nombre, ap_paterno, ap_materno, puesto, horario, fecha_contratacion, salario_mensual, id_hotel) VALUES
-- HOTEL 1
('Carlos', 'Hernández', 'González', 'gerente', 'Mañana', CURDATE(), 30000.00, 1),
('Ana', 'López', 'Jiménez', 'cocinero', 'Tarde', CURDATE(), 15000.00, 1),
('Juan', 'Martínez', 'Morales', 'cocinero', 'Noche', CURDATE(), 15000.00, 1),
('María', 'García', 'Ruiz', 'limpieza', 'Mañana', CURDATE(), 10000.00, 1),
('Luis', 'Rodríguez', 'Chávez', 'limpieza', 'Tarde', CURDATE(), 10000.00, 1),
('Fernanda', 'Pérez', 'Castillo', 'limpieza', 'Noche', CURDATE(), 10000.00, 1),
('Pedro', 'Sánchez', 'Mendoza', 'limpieza', 'Mañana', CURDATE(), 10000.00, 1),
('Gabriela', 'Torres', 'Vargas', 'seguridad', 'Tarde', CURDATE(), 12000.00, 1),
('Miguel', 'Ramírez', 'Ortega', 'seguridad', 'Noche', CURDATE(), 12000.00, 1),
('Laura', 'Flores', 'Delgado', 'recepcionista', 'Mañana', CURDATE(), 14000.00, 1),
('Carlos', 'Hernández', 'Jiménez', 'miselaneo', 'Tarde', CURDATE(), 11000.00, 1),
('Ana', 'López', 'Morales', 'miselaneo', 'Noche', CURDATE(), 11000.00, 1),
('Juan', 'Martínez', 'Ruiz', 'miselaneo', 'Mañana', CURDATE(), 11000.00, 1),
-- HOTEL 2
('María', 'García', 'Chávez', 'gerente', 'Tarde', CURDATE(), 30000.00, 2),
('Luis', 'Rodríguez', 'Castillo', 'cocinero', 'Noche', CURDATE(), 15000.00, 2),
('Fernanda', 'Pérez', 'Mendoza', 'cocinero', 'Mañana', CURDATE(), 15000.00, 2),
('Pedro', 'Sánchez', 'Vargas', 'limpieza', 'Tarde', CURDATE(), 10000.00, 2),
('Gabriela', 'Torres', 'Ortega', 'limpieza', 'Noche', CURDATE(), 10000.00, 2),
('Miguel', 'Ramírez', 'Delgado', 'limpieza', 'Mañana', CURDATE(), 10000.00, 2),
('Laura', 'Flores', 'González', 'limpieza', 'Tarde', CURDATE(), 10000.00, 2),
('Carlos', 'Hernández', 'Jiménez', 'seguridad', 'Noche', CURDATE(), 12000.00, 2),
('Ana', 'López', 'Morales', 'seguridad', 'Mañana', CURDATE(), 12000.00, 2),
('Juan', 'Martínez', 'Ruiz', 'recepcionista', 'Tarde', CURDATE(), 14000.00, 2),
('María', 'García', 'Chávez', 'miselaneo', 'Noche', CURDATE(), 11000.00, 2),
-- HOTEL 3
('Luis', 'Rodríguez', 'Castillo', 'gerente', 'Noche', CURDATE(), 30000.00, 3),
('Fernanda', 'Pérez', 'Mendoza', 'cocinero', 'Mañana', CURDATE(), 15000.00, 3),
('Pedro', 'Sánchez', 'Vargas', 'cocinero', 'Tarde', CURDATE(), 15000.00, 3),
('Gabriela', 'Torres', 'Ortega', 'limpieza', 'Noche', CURDATE(), 10000.00, 3),
('Miguel', 'Ramírez', 'Delgado', 'limpieza', 'Mañana', CURDATE(), 10000.00, 3),
('Laura', 'Flores', 'González', 'limpieza', 'Tarde', CURDATE(), 10000.00, 3),
('Carlos', 'Hernández', 'Jiménez', 'limpieza', 'Noche', CURDATE(), 10000.00, 3),
('Ana', 'López', 'Morales', 'seguridad', 'Mañana', CURDATE(), 12000.00, 3),
('Juan', 'Martínez', 'Ruiz', 'seguridad', 'Tarde', CURDATE(), 12000.00, 3),
('María', 'García', 'Chávez', 'recepcionista', 'Noche', CURDATE(), 14000.00, 3),
('Luis', 'Rodríguez', 'Castillo', 'miselaneo', 'Mañana', CURDATE(), 11000.00, 3),
('Fernanda', 'Pérez', 'Mendoza', 'miselaneo', 'Tarde', CURDATE(), 11000.00, 3),
-- HOTEL 4
('Pedro', 'Sánchez', 'Vargas', 'gerente', 'Mañana', CURDATE(), 30000.00, 4),
('Gabriela', 'Torres', 'Ortega', 'cocinero', 'Tarde', CURDATE(), 15000.00, 4),
('Miguel', 'Ramírez', 'Delgado', 'cocinero', 'Noche', CURDATE(), 15000.00, 4),
('Laura', 'Flores', 'González', 'limpieza', 'Mañana', CURDATE(), 10000.00, 4),
('Carlos', 'Hernández', 'Jiménez', 'limpieza', 'Tarde', CURDATE(), 10000.00, 4),
('Ana', 'López', 'Morales', 'limpieza', 'Noche', CURDATE(), 10000.00, 4),
('Juan', 'Martínez', 'Ruiz', 'limpieza', 'Mañana', CURDATE(), 10000.00, 4),
('María', 'García', 'Chávez', 'seguridad', 'Tarde', CURDATE(), 12000.00, 4),
('Luis', 'Rodríguez', 'Castillo', 'seguridad', 'Noche', CURDATE(), 12000.00, 4),
('Fernanda', 'Pérez', 'Mendoza', 'recepcionista', 'Mañana', CURDATE(), 14000.00, 4),
('Pedro', 'Sánchez', 'Vargas', 'miselaneo', 'Tarde', CURDATE(), 11000.00, 4),
-- HOTEL 5
('Gabriela', 'Torres', 'Ortega', 'gerente', 'Noche', CURDATE(), 30000.00, 5),
('Miguel', 'Ramírez', 'Delgado', 'cocinero', 'Mañana', CURDATE(), 15000.00, 5),
('Laura', 'Flores', 'González', 'cocinero', 'Tarde', CURDATE(), 15000.00, 5),
('Carlos', 'Hernández', 'Jiménez', 'limpieza', 'Noche', CURDATE(), 10000.00, 5),
('Ana', 'López', 'Morales', 'limpieza', 'Mañana', CURDATE(), 10000.00, 5),
('Juan', 'Martínez', 'Ruiz', 'limpieza', 'Tarde', CURDATE(), 10000.00, 5),
('María', 'García', 'Chávez', 'limpieza', 'Noche', CURDATE(), 10000.00, 5),
('Luis', 'Rodríguez', 'Castillo', 'seguridad', 'Mañana', CURDATE(), 12000.00, 5),
('Fernanda', 'Pérez', 'Mendoza', 'seguridad', 'Tarde', CURDATE(), 12000.00, 5),
('Pedro', 'Sánchez', 'Vargas', 'recepcionista', 'Noche', CURDATE(), 14000.00, 5),
('Gabriela', 'Torres', 'Ortega', 'miselaneo', 'Mañana', CURDATE(), 11000.00, 5),
('Miguel', 'Ramírez', 'Delgado', 'miselaneo', 'Tarde', CURDATE(), 11000.00, 5);

-- Insertar en tipos_habitacion
INSERT INTO tipos_habitacion (nombre_tipo, descripcion) VALUES
('Estándar', 'Habitación básica con cama matrimonial'),
('Doble', 'Habitación con dos camas individuales'),
('Suite', 'Habitación de lujo con sala de estar'),
('Familiar', 'Habitación para familias con capacidad para 4 personas'),
('Presidencial', 'Habitación premium con jacuzzi y vistas');

-- Asegurar que tipos_habitacion esté poblada
INSERT IGNORE INTO tipos_habitacion (nombre_tipo, descripcion) VALUES
('Estándar', 'Habitación básica con cama matrimonial'),
('Doble', 'Habitación con dos camas individuales'),
('Suite', 'Habitación de lujo con sala de estar'),
('Familiar', 'Habitación para familias con capacidad para 4 personas'),
('Presidencial', 'Habitación premium con jacuzzi y vistas');
-- Insertar en habitaciones
INSERT INTO habitaciones (num_habitacion, id_hotel, id_tipo, estatus, piso, costo, num_max_huesp) VALUES
(101, 1, 2, 'Disponible', 1, 1200, 2),
(102, 2, 2, 'Ocupada', 1, 1250, 2),
(201, 2, 1, 'Disponible', 2, 1100, 1),
(202, 4, 4, 'Ocupada', 2, 2000, 4),
(301, 3, 3, 'Disponible', 3, 1800, 3),
(302, 1, 1, 'En mantenimiento', 3, 1000, 1),
(401, 4, 2, 'Disponible', 4, 1300, 2),
(402, 3, 1, 'Ocupada', 4, 1150, 1),
(501, 5, 4, 'Disponible', 5, 2100, 4),
(502, 5, 1, 'Disponible', 5, 1050, 1);

-- Insertar en promociones

INSERT INTO promociones (nombre, descripcion, descuento, fecha_inicio, fecha_fin) VALUES
('Descuento Verano', '20% de descuento en estancias de 3 noches', 0.20, '2025-06-01', '2025-08-31'),
('Fin de Semana', '15% de descuento en fines de semana', 0.15, '2025-05-01', '2025-12-31'),
('Paquete Familiar', 'Incluye desayuno gratis para niños', 0.10, '2025-07-01', '2025-09-30'),
('Estancia Larga', '25% de descuento en estancias de 7 noches', 0.25, '2025-01-01', '2025-12-31'),
('Spa Relax', '10% de descuento en servicios de spa', 0.10, '2025-03-01', '2025-06-30');

select * from promociones;
-- Insertar en hoteles_promociones
INSERT INTO hoteles_promociones (id_hotel, id_promocion) VALUES
(1, 1), (1, 2), (2, 3), (2, 4), (3, 5), (3, 1), (4, 2), (4, 3), (5, 4), (5, 5);

-- Insertar en reservaciones
INSERT INTO reservaciones (
    fecha_entrada, fecha_salida, numero_huespedes, estatus, monto, id_cliente
) VALUES
('2025-06-10 14:00:00', '2025-06-15 12:00:00', 2, 'Confirmada', 4500.00, 1),
('2025-07-01 15:00:00', '2025-07-05 12:00:00', 4, 'Confirmada', 7200.00, 2),
('2025-07-10 13:00:00', '2025-07-15 11:00:00', 1, 'Confirmada', 3200.00, 3);

INSERT INTO reservaciones_habitacion (id_reservacion, num_habitacion, id_pago) VALUES
(1, 101, 1),
(2, 102, 2),
(3, 103, 3),
(4, 104, 4),
(5, 105, 5);

-- Insertar hoteles
INSERT INTO hoteles (nombre, calle, num_ext, colonia, codigo_postal, ciudad, id_estado, telefono)
VALUES 
('Hotel Sol del Valle', 'Av. Reforma', '123', 'Centro', '06000', 'Ciudad de México', 1, '555-123-4567'),
('Hotel Azul Marino', 'Calle 5 de Febrero', '45A', 'La Playa', '77500', 'Cancún', 2, '998-456-7890'),
('Hotel Sierra Alta', 'Av. Juárez', '789', 'Zona Norte', '31000', 'Chihuahua', 3, '614-987-6543'),
('Hotel Las Palmas', 'Calle Hidalgo', '10B', 'Centro Histórico', '83000', 'Hermosillo', 4, '662-321-0000'),
('Hotel Nube Blanca', 'Boulevard del Sol', '22', 'Residencial Primavera', '50000', 'Toluca', 5, '722-888-1122');

-- Insertar Servicios
INSERT INTO servicios (nombre_servicio, descripcion, costo)
VALUES 
('desayuno', 'Desayuno continental servido en el comedor', 120.00),
('transporte', 'Transporte al aeropuerto disponible las 24h', 250.00),
('lavandería', 'Servicio de lavandería y planchado', 180.00),
('spa', 'Acceso al spa por 1 hora con masaje incluido', 500.00),
('desayuno', 'Desayuno buffet con opciones internacionales', 180.00),
('spa', 'Spa básico', 200.00);

-- Insertar hoteles_servicios
INSERT INTO hoteles_servicios (id_hotel, id_servicios) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5);

-- Insertar registros de prueba para Pagos
INSERT INTO Pagos (fecha_pago, monto_pago, metodo_pago, comprobante) VALUES
('2024-05-01 14:30:00', 2500.00, 'tarjeta', 'COMP-001'),
('2024-05-02 10:15:00', 1800.50, 'efectivo', 'COMP-002'),
('2024-05-03 16:45:00', 3200.00, 'transferencia', 'COMP-003'),
('2024-05-04 12:00:00', 1500.75, 'tarjeta', 'COMP-004'),
('2024-05-05 09:20:00', 4100.00, 'efectivo', 'COMP-005');

-- Insertar en Clientes_servicios
INSERT INTO Clientes_servicios (id_cliente, id_servicios, id_pago)
VALUES
(1, 2, 3),
(2, 1, 2),
(3, 3, 4),
(4, 4, 1),
(5, 2, 5),
(6, 1, 1),
(7, 2, 2),
(8, 3, 3),
(9, 4, 4),
(10, 5, 5),
(11, 1, 1),
(12, 2, 2),
(13, 3, 3),
(14, 4, 4),
(15, 5, 5);

-- Insertar cliente para probar trigger de nacionalidad
INSERT INTO Clientes (
    CURP, nombre, ap_paterno, ap_materno, fecha_nacimiento,
    email, telefono, calle_numero, colonia, codigo_postal, ciudad, id_estado, pais
) VALUES (
    'LOPE800101HDFRRN09', 'Luis', 'López', 'Ramírez', '1980-01-01',
    'luis.lopez@gmail.com', '5512345678', 'Calle 10 #25', 'Centro', '01000', 'CDMX', 1, 'MX'
);

-- Insertar empleados
INSERT INTO empleados (nombre, ap_paterno, ap_materno, puesto, horario, fecha_contratacion, salario_mensual, id_hotel) VALUES
-- HOTEL 1
('Carlos', 'Hernández', 'González', 'gerente', 'Mañana', CURDATE(), 30000.00, 1),
('Ana', 'López', 'Jiménez', 'cocinero', 'Tarde', CURDATE(), 15000.00, 1),
('Juan', 'Martínez', 'Morales', 'cocinero', 'Noche', CURDATE(), 15000.00, 1),
('María', 'García', 'Ruiz', 'limpieza', 'Mañana', CURDATE(), 10000.00, 1),
('Luis', 'Rodríguez', 'Chávez', 'limpieza', 'Tarde', CURDATE(), 10000.00, 1),
('Fernanda', 'Pérez', 'Castillo', 'limpieza', 'Noche', CURDATE(), 10000.00, 1),
('Pedro', 'Sánchez', 'Mendoza', 'limpieza', 'Mañana', CURDATE(), 10000.00, 1),
('Gabriela', 'Torres', 'Vargas', 'seguridad', 'Tarde', CURDATE(), 12000.00, 1),
('Miguel', 'Ramírez', 'Ortega', 'seguridad', 'Noche', CURDATE(), 12000.00, 1),
('Laura', 'Flores', 'Delgado', 'recepcionista', 'Mañana', CURDATE(), 14000.00, 1),
('Carlos', 'Hernández', 'Jiménez', 'miselaneo', 'Tarde', CURDATE(), 11000.00, 1),
('Ana', 'López', 'Morales', 'miselaneo', 'Noche', CURDATE(), 11000.00, 1),
('Juan', 'Martínez', 'Ruiz', 'miselaneo', 'Mañana', CURDATE(), 11000.00, 1),
-- HOTEL 2
('María', 'García', 'Chávez', 'gerente', 'Tarde', CURDATE(), 30000.00, 2),
('Luis', 'Rodríguez', 'Castillo', 'cocinero', 'Noche', CURDATE(), 15000.00, 2),
('Fernanda', 'Pérez', 'Mendoza', 'cocinero', 'Mañana', CURDATE(), 15000.00, 2),
('Pedro', 'Sánchez', 'Vargas', 'limpieza', 'Tarde', CURDATE(), 10000.00, 2),
('Gabriela', 'Torres', 'Ortega', 'limpieza', 'Noche', CURDATE(), 10000.00, 2),
('Miguel', 'Ramírez', 'Delgado', 'limpieza', 'Mañana', CURDATE(), 10000.00, 2),
('Laura', 'Flores', 'González', 'limpieza', 'Tarde', CURDATE(), 10000.00, 2),
('Carlos', 'Hernández', 'Jiménez', 'seguridad', 'Noche', CURDATE(), 12000.00, 2),
('Ana', 'López', 'Morales', 'seguridad', 'Mañana', CURDATE(), 12000.00, 2),
('Juan', 'Martínez', 'Ruiz', 'recepcionista', 'Tarde', CURDATE(), 14000.00, 2),
('María', 'García', 'Chávez', 'miselaneo', 'Noche', CURDATE(), 11000.00, 2),
-- HOTEL 3
('Luis', 'Rodríguez', 'Castillo', 'gerente', 'Noche', CURDATE(), 30000.00, 3),
('Fernanda', 'Pérez', 'Mendoza', 'cocinero', 'Mañana', CURDATE(), 15000.00, 3),
('Pedro', 'Sánchez', 'Vargas', 'cocinero', 'Tarde', CURDATE(), 15000.00, 3),
('Gabriela', 'Torres', 'Ortega', 'limpieza', 'Noche', CURDATE(), 10000.00, 3),
('Miguel', 'Ramírez', 'Delgado', 'limpieza', 'Mañana', CURDATE(), 10000.00, 3),
('Laura', 'Flores', 'González', 'limpieza', 'Tarde', CURDATE(), 10000.00, 3),
('Carlos', 'Hernández', 'Jiménez', 'limpieza', 'Noche', CURDATE(), 10000.00, 3),
('Ana', 'López', 'Morales', 'seguridad', 'Mañana', CURDATE(), 12000.00, 3),
('Juan', 'Martínez', 'Ruiz', 'seguridad', 'Tarde', CURDATE(), 12000.00, 3),
('María', 'García', 'Chávez', 'recepcionista', 'Noche', CURDATE(), 14000.00, 3),
('Luis', 'Rodríguez', 'Castillo', 'miselaneo', 'Mañana', CURDATE(), 11000.00, 3),
('Fernanda', 'Pérez', 'Mendoza', 'miselaneo', 'Tarde', CURDATE(), 11000.00, 3),
-- HOTEL 4
('Pedro', 'Sánchez', 'Vargas', 'gerente', 'Mañana', CURDATE(), 30000.00, 4),
('Gabriela', 'Torres', 'Ortega', 'cocinero', 'Tarde', CURDATE(), 15000.00, 4),
('Miguel', 'Ramírez', 'Delgado', 'cocinero', 'Noche', CURDATE(), 15000.00, 4),
('Laura', 'Flores', 'González', 'limpieza', 'Mañana', CURDATE(), 10000.00, 4),
('Carlos', 'Hernández', 'Jiménez', 'limpieza', 'Tarde', CURDATE(), 10000.00, 4),
('Ana', 'López', 'Morales', 'limpieza', 'Noche', CURDATE(), 10000.00, 4),
('Juan', 'Martínez', 'Ruiz', 'limpieza', 'Mañana', CURDATE(), 10000.00, 4),
('María', 'García', 'Chávez', 'seguridad', 'Tarde', CURDATE(), 12000.00, 4),
('Luis', 'Rodríguez', 'Castillo', 'seguridad', 'Noche', CURDATE(), 12000.00, 4),
('Fernanda', 'Pérez', 'Mendoza', 'recepcionista', 'Mañana', CURDATE(), 14000.00, 4),
('Pedro', 'Sánchez', 'Vargas', 'miselaneo', 'Tarde', CURDATE(), 11000.00, 4),
-- HOTEL 5
('Gabriela', 'Torres', 'Ortega', 'gerente', 'Noche', CURDATE(), 30000.00, 5),
('Miguel', 'Ramírez', 'Delgado', 'cocinero', 'Mañana', CURDATE(), 15000.00, 5),
('Laura', 'Flores', 'González', 'cocinero', 'Tarde', CURDATE(), 15000.00, 5),
('Carlos', 'Hernández', 'Jiménez', 'limpieza', 'Noche', CURDATE(), 10000.00, 5),
('Ana', 'López', 'Morales', 'limpieza', 'Mañana', CURDATE(), 10000.00, 5),
('Juan', 'Martínez', 'Ruiz', 'limpieza', 'Tarde', CURDATE(), 10000.00, 5),
('María', 'García', 'Chávez', 'limpieza', 'Noche', CURDATE(), 10000.00, 5),
('Luis', 'Rodríguez', 'Castillo', 'seguridad', 'Mañana', CURDATE(), 12000.00, 5),
('Fernanda', 'Pérez', 'Mendoza', 'seguridad', 'Tarde', CURDATE(), 12000.00, 5),
('Pedro', 'Sánchez', 'Vargas', 'recepcionista', 'Noche', CURDATE(), 14000.00, 5),
('Gabriela', 'Torres', 'Ortega', 'miselaneo', 'Mañana', CURDATE(), 11000.00, 5),
('Miguel', 'Ramírez', 'Delgado', 'miselaneo', 'Tarde', CURDATE(), 11000.00, 5);

-- Insertar en tipos_habitacion
INSERT INTO tipos_habitacion (nombre_tipo, descripcion) VALUES
('Estándar', 'Habitación básica con cama matrimonial'),
('Doble', 'Habitación con dos camas individuales'),
('Suite', 'Habitación de lujo con sala de estar'),
('Familiar', 'Habitación para familias con capacidad para 4 personas'),
('Presidencial', 'Habitación premium con jacuzzi y vistas');

show tables;

select * from tipos_habitacion;
-- Asegurar que tipos_habitacion esté poblada
INSERT IGNORE INTO tipos_habitacion (nombre_tipo, descripcion) VALUES
('Estándar', 'Habitación básica con cama matrimonial'),
('Doble', 'Habitación con dos camas individuales'),
('Suite', 'Habitación de lujo con sala de estar'),
('Familiar', 'Habitación para familias con capacidad para 4 personas'),
('Presidencial', 'Habitación premium con jacuzzi y vistas');
-- Insertar en habitaciones
INSERT INTO habitaciones (num_habitacion, id_hotel, id_tipo, estatus, piso, costo, num_max_huesp) VALUES
(101, 1, 2, 'Disponible', 1, 1200, 2),
(102, 2, 2, 'Ocupada', 1, 1250, 2),
(201, 2, 1, 'Disponible', 2, 1100, 1),
(202, 4, 4, 'Ocupada', 2, 2000, 4),
(301, 3, 3, 'Disponible', 3, 1800, 3),
(302, 1, 1, 'En mantenimiento', 3, 1000, 1),
(401, 4, 2, 'Disponible', 4, 1300, 2),
(402, 3, 1, 'Ocupada', 4, 1150, 1),
(501, 5, 4, 'Disponible', 5, 2100, 4),
(502, 5, 1, 'Disponible', 5, 1050, 1);


select * from habitaciones;
select * from clientes;

-- Insertar en promociones

INSERT INTO promociones (nombre, descripcion, descuento, fecha_inicio, fecha_fin) VALUES
('Descuento Verano', '20% de descuento en estancias de 3 noches', 0.20, '2025-06-01', '2025-08-31'),
('Fin de Semana', '15% de descuento en fines de semana', 0.15, '2025-05-01', '2025-12-31'),
('Paquete Familiar', 'Incluye desayuno gratis para niños', 0.10, '2025-07-01', '2025-09-30'),
('Estancia Larga', '25% de descuento en estancias de 7 noches', 0.25, '2025-01-01', '2025-12-31'),
('Spa Relax', '10% de descuento en servicios de spa', 0.10, '2025-03-01', '2025-06-30');

select * from promociones;
-- Insertar en hoteles_promociones
INSERT INTO hoteles_promociones (id_hotel, id_promocion) VALUES
(1, 1), (1, 2), (2, 3), (2, 4), (3, 5), (3, 1), (4, 2), (4, 3), (5, 4), (5, 5);


-- Views----------------------------------------------------------------------
USE Trivago;

-- 1. Vista de Reservaciones Detalladas
CREATE OR REPLACE VIEW vista_reservaciones_detalladas AS
SELECT 
    r.id_reservacion,
    r.fecha_entrada,
    r.fecha_salida,
    r.numero_huespedes,
    r.estatus AS estatus_reservacion,
    r.monto AS monto_reservacion,
    c.id_cliente,
    CONCAT(c.nombre, ' ', c.ap_paterno, ' ', COALESCE(c.ap_materno, '')) AS nombre_cliente,
    c.email,
    c.telefono,
    h.nombre AS nombre_hotel,
    h.ciudad,
    rh.num_habitacion,
    th.nombre_tipo AS tipo_habitacion
FROM reservaciones r
JOIN Clientes c ON r.id_cliente = c.id_cliente
JOIN reservaciones_habitacion rh ON r.id_reservacion = rh.id_reservacion
JOIN habitaciones hab ON rh.num_habitacion = hab.num_habitacion
JOIN hoteles h ON hab.id_hotel = h.id_hotel
JOIN tipos_habitacion th ON hab.id_tipo = th.id_tipo
WHERE r.estatus = 'Confirmada';

-- 2. Vista de Servicios por Hotel
CREATE OR REPLACE VIEW vista_servicios_por_hotel AS
SELECT 
    h.id_hotel,
    h.nombre AS nombre_hotel,
    h.ciudad,
    s.nombre_servicio,
    s.descripcion,
    s.costo
FROM hoteles h
JOIN hoteles_servicios hs ON h.id_hotel = hs.id_hotel
JOIN servicios s ON hs.id_servicios = s.id_servicios
ORDER BY h.id_hotel, s.nombre_servicio;

-- 3. Vista de Pagos por Cliente
CREATE OR REPLACE VIEW vista_pagos_por_cliente AS
SELECT 
    c.id_cliente,
    CONCAT(c.nombre, ' ', c.ap_paterno, ' ', COALESCE(c.ap_materno, '')) AS nombre_cliente,
    p.id_pago,
    p.fecha_pago,
    p.monto_pago,
    p.metodo_pago,
    COALESCE(s.nombre_servicio, 'No especificado') AS nombre_servicio,
    p.comprobante
FROM Clientes c
LEFT JOIN Clientes_servicios cs ON c.id_cliente = cs.id_cliente
LEFT JOIN servicios s ON cs.id_servicios = s.id_servicios
LEFT JOIN Pagos p ON cs.id_pago = p.id_pago
WHERE p.id_pago IS NOT NULL
ORDER BY p.fecha_pago DESC;

-- 4. Vista de Habitaciones Disponibles
CREATE OR REPLACE VIEW vista_habitaciones_disponibles AS
SELECT 
    h.id_hotel,
    h.nombre AS nombre_hotel,
    h.ciudad,
    hab.num_habitacion,
    th.nombre_tipo AS tipo_habitacion,
    hab.costo,
    hab.num_max_huesp AS capacidad,
    hab.piso
FROM habitaciones hab
JOIN hoteles h ON hab.id_hotel = h.id_hotel
JOIN tipos_habitacion th ON hab.id_tipo = th.id_tipo
WHERE hab.estatus = 'Disponible'
ORDER BY h.id_hotel, hab.num_habitacion;

-- 5. Vista de Promociones Activas
CREATE OR REPLACE VIEW vista_promociones_activas AS
SELECT 
    p.id_promocion,
    p.nombre AS nombre_promocion,
    p.descripcion,
    p.descuento * 100 AS porcentaje_descuento,
    p.fecha_inicio,
    p.fecha_fin,
    h.nombre AS nombre_hotel,
    h.ciudad
FROM promociones p
JOIN hoteles_promociones hp ON p.id_promocion = hp.id_promocion
JOIN hoteles h ON hp.id_hotel = h.id_hotel
WHERE p.fecha_inicio <= NOW() AND p.fecha_fin >= NOW()
ORDER BY p.fecha_fin;

-- 6. Vista de Empleados por Hotel
CREATE OR REPLACE VIEW vista_empleados_por_hotel AS
SELECT 
    h.id_hotel,
    h.nombre AS nombre_hotel,
    h.ciudad,
    e.id_empleados,
    CONCAT(e.nombre, ' ', e.ap_paterno, ' ', COALESCE(e.ap_materno, '')) AS nombre_empleado,
    e.puesto,
    e.horario,
    e.salario_mensual,
    e.fecha_contratacion
FROM empleados e
JOIN hoteles h ON e.id_hotel = h.id_hotel
ORDER BY h.id_hotel, e.puesto, e.horario;