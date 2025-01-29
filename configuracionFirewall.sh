#!/bin/bash

# Limpiar reglas existentes
sudo iptables -F
sudo iptables -X

# Establecer políticas predeterminadas
#sudo iptables -P INPUT DROP
#sudo iptables -P FORWARD DROP
#sudo iptables -P OUTPUT ACCEPT

# Permitir conexiones locales
#sudo iptables -A INPUT -i lo -j ACCEPT
#sudo iptables -A OUTPUT -o lo -j ACCEPT


# Registrar el tráfico de control desde la red interna a cualquier ubicación
sudo iptables -I INPUT 1 -i enp0s8 -m conntrack --ctstate NEW,RELATED,ESTABLISHED -j LOG --log-prefix "Trafico Interno:"



# Permitir conexión al servicio web de srv_interno desde la máquina firewall
sudo iptables -A OUTPUT -p tcp -d srv_interno_ip --dport 80 -j ACCEPT
sudo iptables -A INPUT -p tcp -s srv_interno_ip --sport 80 -j ACCEPT

# Permitir conexión al servicio web de firewall desde cualquier nodo
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# Permitir conexiones locales para acceder a un servidor FTP en srv_interno
sudo iptables -A OUTPUT -p tcp -d srv_interno_ip --dport 21 -j ACCEPT
sudo iptables -A INPUT -p tcp -s srv_interno_ip --sport 21 -j ACCEPT

# Permitir conexiones a la máquina firewall desde cualquier servidor de la red interna
sudo iptables -A INPUT -i enp0s8 -p tcp --dport 22 -j ACCEPT

# Permitir conexión mediante ssh a srv_interno a través del puerto 9922 desde srv_externo
sudo iptables -A INPUT -i enp0s3 -p tcp --dport 9922 -s srv_externo_ip -j ACCEPT
sudo iptables -A OUTPUT -o enp0s3 -p tcp --sport 9922 -d srv_externo_ip -j ACCEPT

# Permitir conexiones DNS externas desde srv_interno
sudo iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
sudo iptables -A INPUT -p udp --sport 53 -j ACCEPT

# Permitir conexiones de salida a servidores web externos desde srv_interno (en una única regla)
sudo iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT

# Peticiones ping desde el servidor externo al interno y viceversa
sudo iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
sudo iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT

# Limitar respuesta de ping a una petición cada 2 segundos
sudo iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 2/second -j ACCEPT

# Añadir regla basada en la inspección de estados que permita la entrada de cualquier datagrama a la máquina firewall, siempre que no sea el primer datagrama de una comunicación.
sudo iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# Agregar regla al final de INPUT para loggear y descartar el resto del tráfico
sudo iptables -A INPUT -j LOG --log-prefix "Default-Drop:" --log-level 7
sudo iptables -A INPUT -j DROP

# Agregar regla al final de OUTPUT para loggear y descartar el resto del tráfico
sudo iptables -A OUTPUT -j LOG --log-prefix "Default-Drop:" --log-level 7
sudo iptables -A OUTPUT -j DROP

