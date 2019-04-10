# golang-oci

Multi-stage docker build to extend golang with oci, et al to connect to oracle db:  

1. Oracle Instant Client: using oracle linux to install instant client per   

    https://github.com/oracle/docker-images/blob/master/OracleInstantClient

2. Golang: copy OIC (with OCI) from previous stage into official golang image

