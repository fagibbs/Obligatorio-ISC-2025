# Obligatorio-ISC-2025
Lo primero que hicimos fue armar un esquema en draw.io para tener una idea general de cómo iba a quedar todo. Eso nos ayudó a ver la arquitectura antes de arrancar con Terraform. 
Después empezamos por la red. Creamos una VPC y la dividimos en subnets públicas y privadas. También trabajamos en dos AZ para la alta disponibilidad. En las subnets públicas pusimos el Load Balancer y el NAT Gateway. El NAT lo agregamos porque las instancias privadas precisan conectarse hacia afuera para actualizar paquetes, pero no queríamos que tengan IP pública. El Internet Gateway quedó asociado a la parte pública, que es la que tiene que salir directo a internet. 

Luego armamos el Application Load Balancer, que es el que recibe el tráfico del sitio. Le configuramos health checks para asegurarnos de que no mande tráfico a una instancia caída. También, generamos los logs para el trafico del ALB en S3, simplemente para tener un registro en caso de tener que revisar algo en el futuro. 

Para la aplicación usamos Auto Scaling Group. Con eso, si sube la carga, se levantan más instancias sin que tengamos que intervenir, siendo escalable dependiendo el trafico. En principio el Launch Template instala Apache y deja una página simple para chequear que la instancia esté respondiendo, pero es adaptable con la página de la empresa. 

Para la base de datos optamos directamente por RDS. Nos simplificó los backups, la disponibilidad y el failover. Elegimos MySQL Multi-AZ y definimos el DB Subnet Group con las subnets privadas que destinamos para las DB. 

Respecto a seguridad lo que hicimos fue que el ALB reciba tráfico externo, y la aplicación solo recibe tráfico desde él. Además la base solo acepta conexiones desde la aplicación. Con eso evitamos exponer los datos a ataques. 

Para organizar todo, separamos en módulos para que el proyecto quede ordenado y sea fácilmente modificable. Intentamos usar variables lo máximo posible y outputs para no repetir valores y enlazar los módulos sin apilar todo en un solo archivo.
