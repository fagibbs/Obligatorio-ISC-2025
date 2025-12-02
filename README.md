# Obligatorio-ISC-2025
Lo primero que hicimos fue armar un esquema en draw.io para tener una idea general de cómo iba a quedar todo. Eso nos ayudó a ver la arquitectura antes de arrancar con Terraform. 
Después empezamos por la red. Creamos una VPC y la dividimos en subnets públicas y privadas. También trabajamos en dos AZ para la alta disponibilidad. En las subnets públicas pusimos el Load Balancer y el NAT Gateway. El NAT lo agregamos porque las instancias privadas precisan conectarse hacia afuera para actualizar paquetes, pero no queríamos que tengan IP pública. El Internet Gateway quedó asociado a la parte pública, que es la que tiene que salir directo a internet. 

Luego armamos el Application Load Balancer, que es el que recibe el tráfico del sitio. Le configuramos health checks para asegurarnos de que no mande tráfico a una instancia caída. También, generamos los logs para el trafico del ALB en S3, simplemente para tener un registro en caso de tener que revisar algo en el futuro. 

Para la aplicación usamos Auto Scaling Group. Con eso, si sube la carga, se levantan más instancias sin que tengamos que intervenir, siendo escalable dependiendo el trafico. En principio el Launch Template instala Apache y deja una página simple para chequear que la instancia esté respondiendo, pero es adaptable con la página de la empresa. 

Para la base de datos optamos directamente por RDS. Nos simplificó los backups, la disponibilidad y el failover. Elegimos MySQL Multi-AZ y definimos el DB Subnet Group con las subnets privadas que destinamos para las DB. 

Respecto a seguridad lo que hicimos fue que el ALB reciba tráfico externo, y la aplicación solo recibe tráfico desde él. Además la base solo acepta conexiones desde la aplicación. Con eso evitamos exponer los datos a ataques. 

Para organizar todo, separamos en módulos para que el proyecto quede ordenado y sea fácilmente modificable. Intentamos usar variables lo máximo posible y outputs para no repetir valores y enlazar los módulos sin apilar todo en un solo archivo.

**Instructivo de uso:**

Clonar el repositorio:
git clone https://github.com/fagibbs/Obligatorio-ISC-2025.git
cd Obligatorio-ISC-2025/Terraform

Configurar credenciales AWS:
aws configure
(Completar)
AWS Access Key ID
AWS Secret Access Key
Región -> us-east-1

Inicializar Terraform
terraform init

Ver el plan
terraform plan

Aplicar a la infraestructura
terraform apply

************(En caso de ser necesario) ************
terraform destroy
************(En caso de ser necesario) ************

**Diagrama de Arquitectura**
Obligatorio-ISC-2025/Obligatorio ISC.jpg

**Descripción general de la arquitectura**
La infraestructura se basa en una arquitectura de tres capas:

-	Capa Pública
Application Load Balancer
Subnets públicas (AZ1 y AZ2)
Internet Gateway
NAT Gateway

-	Capa de Aplicación
Auto Scaling Group (2 a 6 instancias)
Launch Template con Amazon Linux 2 + Apache instalado vía user_data
Subnets privadas (AZ1 y AZ2)
Seguridad estricta: solo recibe tráfico del ALB

-	Capa de Base de Datos
RDS MySQL
Subnets privadas aisladas
Accesible únicamente desde las instancias de aplicación

-	Acompañado de:
S3 para logs del ALB
Alarmas CloudWatch (latencia alta / sin instancias saludables)
Seguridad mediante SG segmentados por rol
Logging centralizado

**Datos de la infraestructura**
VPC

-	CIDR: 10.0.0.0/16
Subnets

Públicas
- 10.0.1.0/24 (AZ1)
- 10.0.2.0/24 (AZ2)

Privadas – App
- 10.0.10.0/24 (AZ1)
- 10.0.11.0/24 (AZ2)

Privadas – DB
- 10.0.20.0/24 (AZ1)
- 10.0.21.0/24 (AZ2)

Application Load Balancer
-	Listens: HTTP/80
-	Logs enviados a S3
-	Target Group asociado con health checks /

AutoScaling – Capa APP
-	Launch Template con Apache + index.html
-	Capacidad: Min 2 / Max 6
-	Security Group acepta solo desde ALB

Base de Datos
-	RDS MySQL o EC2 t3.micro según versión del equipo
-	Acceso exclusivo desde SG de la aplicación
-	Sin IP pública

Security Groups
-	ALB: permite HTTP desde 0.0.0.0/0
-	APP: permite HTTP solo desde SG del ALB
-	DB: permite 3306 solo desde SG APP

NAT Gateway
-	Permite salida a internet desde subnets privadas (App/DB)

Logs
-	Bucket S3 para logs del ALB
-	Política IAM para permitir escritura del servicio ELB

Alarmas CloudWatch
-	alb-no-healthy-targets – Detecta si el ALB se queda sin instancias sanas
-	alb-high-latency – Detecta latencia excesiva en respuestas

**Servicios AWS que utilizamos:**
-	VPC
-	Subnets (públicas/privadas)
-	Route Tables + Associations
-	Internet Gateway
-	NAT Gateway
-	Elastic IP
-	EC2
-	Auto Scaling Group
-	Launch Template
-	Application Load Balancer
-	Target Group
-	S3 (logs)
-	CloudWatch (alarmas)
-	IAM implícito (políticas de acceso para logs)
-	RDS

**Requerimientos:**
Software Necesario
-	Terraform 1.5+
-	AWS CLI 2.x
-	Git
-	Key Pair creado en us-east-1

**Providers Terraform**
Declarados en providers.tf:
-	hashicorp/aws
-	hashicorp/random

**Autores:**
Joaquín Manzanar – N° 280373
Facundo Gibbs – N° 253768
