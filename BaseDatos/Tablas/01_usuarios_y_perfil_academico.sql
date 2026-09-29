drop table if exists
	certificaciones, egresados_carreras, egresados, carreras, facultades,
	usuarios, roles_permisos, permisos, roles
cascade;

create table roles (
	id_rol serial primary key,
	nombre varchar(50) not null,
	constraint uq_nombre_rol unique (nombre)
	);

create table permisos (
	id_permiso serial primary key,
	clave varchar(100) not null,
	descripcion varchar(255),
	constraint uq_clave_permiso unique (clave)
	);

create table roles_permisos (
	id_rol int,
	id_permiso int,
	primary key (id_rol, id_permiso),

	constraint fk_roles_permisos_rol
		foreign key (id_rol)
		references roles(id_rol)
		on delete cascade,

	constraint fk_roles_permisos_permiso
		foreign key (id_permiso)
		references permisos(id_permiso)
		on delete cascade
	);

create table usuarios (
	id_usuario serial primary key,
	id_rol int not null,
	correo varchar(255) not null,
	contrasena_cifrada varchar(255) not null,
	fecha_registro timestamp not null default current_timestamp,
	activo boolean not null default true,
	constraint uq_correo_usuario unique (correo),

	constraint fk_usuarios_rol
		foreign key (id_rol)
		references roles(id_rol)
	);

create table facultades (
	id_facultad serial primary key,
	nombre varchar(150) not null,
	constraint uq_nombre_facultad unique (nombre)
	);

create table carreras (
	id_carrera serial primary key,
	id_facultad int not null,
	nombre varchar(150) not null,
	nivel varchar(30) not null,
	constraint uq_carrera_facultad unique (id_facultad, nombre),

	constraint fk_carreras_facultad
		foreign key (id_facultad)
		references facultades(id_facultad)
	);

create table egresados (
	id_egresado serial primary key,
	id_usuario int not null,
	nombres varchar(100) not null,
	apellidos varchar(100) not null,
	telefono varchar(20),
	biografia text,
	enlace_linkedin varchar(255),
	constraint uq_usuario_egresado unique (id_usuario),

	constraint fk_egresados_usuario
		foreign key (id_usuario)
		references usuarios(id_usuario)
		on delete cascade
	);

create table egresados_carreras (
	id_egresado int,
	id_carrera int,
	anio_inicio int not null,
	anio_graduacion int,
	promedio decimal(5,2),
	primary key (id_egresado, id_carrera),
	constraint check_promedio_valido check (promedio between 0 and 100),
	constraint check_anios_validos check (anio_graduacion is null or anio_graduacion >= anio_inicio),

	constraint fk_egresados_carreras_egresado
		foreign key (id_egresado)
		references egresados(id_egresado)
		on delete cascade,

	constraint fk_egresados_carreras_carrera
		foreign key (id_carrera)
		references carreras(id_carrera)
	);

create table certificaciones (
	id_certificacion serial primary key,
	id_egresado int not null,
	nombre varchar(200) not null,
	institucion_emisora varchar(200),
	fecha_emision date,
	enlace_credencial varchar(255),

	constraint fk_certificaciones_egresado
		foreign key (id_egresado)
		references egresados(id_egresado)
		on delete cascade
	);
