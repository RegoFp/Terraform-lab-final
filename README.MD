# Arquitectura

## Arquitectura General

![image](https://github.com/RegoFp/Terraform-lab-final/blob/cf9632634b74f12be0578a56aa617a2edaa60533/resources/diagrama.png?raw=true)

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

En esta arquitectura, el **Network Load Balancer (NLB)** y el **Application Load Balancer (ALB)** se usan juntos para gestionar el tráfico de manera eficiente. Cada uno cumple un papel específico:

### Network Load Balancer (NLB)

- **Función**: El NLB es el primer punto de entrada para todo el tráfico. Se encarga de recibir grandes volúmenes de conexiones rápidamente y dirigirlas hacia el ALB.
- **Ventaja**: Es ideal para manejar mucho tráfico a muy baja latencia, funcionando como una “primera línea” de balanceo.

### Application Load Balancer (ALB)

- **Función**: Una vez que el tráfico llega al ALB desde el NLB, el ALB distribuye las solicitudes entre las instancias de WordPress.
- **Ventaja**: Permite decidir a qué servidor de WordPress enviar cada solicitud, optimizando la experiencia del usuario.


En resumen, el NLB y el ALB trabajan en conjunto para distribuir el tráfico de manera rápida y organizada, asegurando que WordPress funcione de forma estable y escalable.

## Cache

En esta arquitectura, se utilizan diferentes capas de caché para mejorar el rendimiento de WordPress. Cada uno de estos componentes de caché tiene un propósito específico:

### 1. Redis como Caché de Base de Datos y Consultas

- **Función**: Redis almacena en caché datos dinámicos y consultas a la base de datos, como el contenido de las publicaciones y los resultados de consultas frecuentes.
- **Ventaja**: Reduce la cantidad de solicitudes a la base de datos, lo que hace que las páginas se carguen más rápido y se alivie la carga en el sistema de base de datos. Redis es ideal para datos de rápido acceso que se consultan repetidamente.

### 2. Memcached para la Caché de Sesiones

- **Función**: Memcached almacena las sesiones de los usuarios (como las credenciales y el estado de inicio de sesión) para que cualquier instancia de WordPress en el grupo pueda acceder a ellas.
- **Ventaja**: Esto permite que los usuarios mantengan su sesión activa sin importar en qué servidor de WordPress estén, lo cual es esencial en un ambiente con múltiples servidores. Memcached es rápido y eficiente para almacenar datos de sesión temporales.

### Beneficios de Usar Múltiples Cachés

- **Menos carga en el servidor**: Las cachés distribuyen la carga entre los servidores, la base de datos y las instancias de WordPress.
- **Mayor velocidad**: Cada capa de caché mejora la rapidez con que se sirve el contenido, manteniendo el sitio rápido y receptivo.
- **Escalabilidad**: Este sistema de caché combinado permite que WordPress maneje altos volúmenes de tráfico sin afectar la experiencia del usuario.

En conjunto, estas soluciones de caché optimizan el desempeño de WordPress, mejorando tanto la velocidad como la capacidad de respuesta del sitio web.

## Uso de Route 53 para Endpoints Internos

En esta arquitectura, **Route 53** se utiliza para crear endpoints internos que permiten que los distintos servicios y recursos se comuniquen entre sí sin depender de sus direcciones IP específicas. Esto asegura que, incluso si los endpoints cambian los recursos puedan seguir conectándose mediante nombres DNS internos.

### Cómo Funciona Route 53 para Endpoints Internos

- **Resolución DNS Privada**: Route 53 permite la resolución de estos nombres DNS internos solo dentro de la VPC. Esto significa que los recursos pueden comunicarse entre ellos usando estos nombres en lugar de direcciones IP.

- **Conexión entre Recursos**: En lugar de que las aplicaciones o servicios se conecten mediante una IP directa, se conectan usando los nombres DNS internos de Route 53. Esto simplifica la configuración, ya que no necesitan conocer las IPs internas exactas, que pueden cambiar con el tiempo.


### Ejemplo Práctico

Si una instancia de WordPress necesita conectarse a la base de datos, en lugar de usar la IP de la base de datos, simplemente se conecta a `db.backend.com`. Esto asegura que, incluso si el endpoint de la base de datos cambia, WordPress puede seguir accediendo sin ninguna reconfiguración adicional.

En resumen, Route 53 facilita la comunicación interna entre servicios en la VPC de forma flexible y segura, independientemente de los cambios de IP de los recursos.

## Cloudfront
**CloudFront** es una red de distribución de contenido (CDN) de Amazon que hace que los sitios web sean más rápidos y seguros al entregar contenido estático, como imágenes y archivos, desde servidores distribuidos por todo el mundo.


1. **Mayor Velocidad**  
CloudFront guarda copias del contenido en servidores (llamados “Edge Locations”) cercanos a los usuarios. Que reciben el contenido desde el servidor más cercano, lo que reduce el tiempo de carga.

2. **Menos Carga en el Servidor Principal**  
CloudFront maneja el contenido estático, como imágenes y archivos, para que el servidor principal no tenga que hacerlo cada vez.Esto libera recursos en el servidor principal, ayudando a manejar más tráfico y solicitudes dinámicas.

### Resumen

CloudFront acelera el sitio, reduce la carga en el servidor, mejora la seguridad y ayuda a reducir costos, lo cual es ideal para sitios web que manejan mucho tráfico o contenido estático.

## Punto de Entrada a la Arquitectura

El punto de entrada principal a la arquitectura será el **DNS de CloudFront**, el cual se generará y estará disponible en los outputs de Terraform una vez que la infraestructura esté completamente implementada.

> **Nota**: La arquitectura podría no estar accesible de inmediato al finalizar el `apply`. Puede ser necesario esperar algunos minutos para que WordPress establezca conexión con la base de datos y todos los servicios estén completamente operativos.
