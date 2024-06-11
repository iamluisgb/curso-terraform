# Terraform

## Introducción

### ¿Por qué Terraform?

- **Entrega de software:** El software no está terminado hasta que se entrega al usuario. La entrega incluye ejecutar el código en producción, hacerlo resistente a interrupciones y protegerlo de atacantes.
- **Panorama general:** Terraform se ubica en el contexto más amplio de la entrega de software y DevOps, ayudando a automatizar la gestión de la infraestructura.

### ¿Qué es DevOps?

- **Evolución de la gestión de hardware:** Antes, era necesario gestionar mucho hardware manualmente. Ahora, muchas empresas migran a la nube, utilizando servicios como AWS, Azure y GCP.
- **Movimiento DevOps:** Surge para hacer más eficiente la entrega de software. Dev y Ops trabajan juntos, automatizando procesos para evitar problemas comunes como despliegues lentos y errores de configuración.

## Infraestructura como Código (IaC)

### ¿Qué es IaC?

- **Concepto:** Escribir y ejecutar código para definir, implementar, actualizar y destruir infraestructura. Se trata todo como software, incluso aspectos que representan hardware.
- **Categorías de herramientas IaC:**
  1. Guiones ad hoc
  2. Herramientas de gestión de configuración
  3. Herramientas de plantillas de servidor
  4. Herramientas de orquestación
  5. Herramientas de aprovisionamiento

### Beneficios de IaC

- **Poder del código:** La infraestructura definida como código permite mejorar la entrega de software. Organizaciones que adoptan DevOps e IaC implementan más frecuentemente, se recuperan más rápido de fallas y tienen menores tiempos de entrega.

## Herramientas y Técnicas

### Guiones ad hoc

- **Sencillo pero limitado:** Los scripts ad hoc son útiles para tareas pequeñas y únicas, pero se vuelven complicados y difíciles de mantener en proyectos grandes.

### Herramientas de gestión de configuración

- **Ejemplos:** Chef, Puppet, Ansible.
- **Ventajas:** Convenciones de codificación, idempotencia, y gestión de múltiples servidores remotos.

### Herramientas de plantillas de servidor

- **Ejemplos:** Docker, Packer, Vagrant.
- **Enfoque:** Crear imágenes de servidor que capturan una "instantánea" autónoma del sistema operativo y software.

### Herramientas de orquestación

- **Ejemplos:** Kubernetes, Marathon/Mesos, Amazon ECS, Docker Swarm, Nomad.
- **Objetivo:** Gestionar el despliegue, monitoreo, y escalado de contenedores y máquinas virtuales.

### Herramientas de aprovisionamiento

- **Ejemplos:** Terraform, CloudFormation, OpenStack Heat, Pulumi.
- **Función:** Crear y gestionar servidores, bases de datos, balanceadores de carga, y otros aspectos de la infraestructura.

##  Empezando con Terraform

- **Instalación**
- **HCL**
- **Actualizar y Destruir Infraestructura**
- **Proveedores**
-**Variables**

## Estado de Terraform

- **¿Qué es el estado de Terraform?**
- **Despliegue de infraestructura en AWS**

### Módulos

- **¿Qué son los módulos?**
- **Creando y usando un módulo**
- **Terraform Registry**

### Funciones y condicionales
- **Funciones**
- **Condicionales**

## Recursos Adicionales

- **Documentación oficial:** [Terraform Documentation](https://www.terraform.io/docs)
