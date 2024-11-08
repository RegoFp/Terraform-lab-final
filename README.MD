# Arquitectura

## Arquitectura General

Esta configuración de Terraform implementa una arquitectura en AWS optimizada para alojar instancias de WordPress. Los principales recursos generados incluyen:


- **VPC (Virtual Private Cloud)**: Una red privada y segura que aloja todos los componentes de la infraestructura.
- **Internet Gateway (IGW)**: Permite a la VPC conectarse a Internet, asegurando el acceso externo cuando sea necesario.

- **Network Load Balancer (NLB)**: Distribuye el tráfico a nivel de red.

- **Application Load Balancer (ALB)**: Distribuye el tráfico a nivel de aplicación permitiendo un balanceo de carga más flexible y enrutamiento según las necesidades de la aplicación.

- **Auto Scaling Group (ASG)**: Gestiona el escalado automático de las instancias de WordPress, ajustando la cantidad de servidores según la demanda para optimizar recursos y costos.

- **Caché de Sesión**: Acelera el rendimiento guardando las sesiones de usuario, mejorando tiempos de respuesta.

- **Caché de Contenido**: Almacena contenido estático para reducir la carga en los servidores y agilizar la entrega de recursos a los usuarios.

- **CloudFront**: Servicio de CDN (Content Delivery Network) que distribuye contenido de forma rápida a usuarios de todo el mundo mediante una red global de servidores.

- **Elastic File System (EFS)**: Proporciona almacenamiento compartido entre todas las instancias de WordPress.

- **Bucket S3**: Almacenamiento adicional en S3 para multimedia subido a wordpress.

- **RDS PostgreSQL**: Una base de datos administrada y confiable para WordPress, que asegura almacenamiento de datos persistente y alta disponibilidad.

### Implementación de WordPress

Las instancias de WordPress se crean a partir de una **AMI (Amazon Machine Image)** preconfigurada, lo que permite un despliegue rápido y consistente de la aplicación.
Contiene: 
- Wordpress con plugin para funcionar con postgresSQL.
- Plugin para cachear contenido en redis.
- Plugin para almacenar imagenes en un bucket S3.
- Configuracion PHP para guardar sesiones en un memcached.

## Distribucion de carga.