# BAMCIS AWS Glue Zeppelin Notebook Container

This project is for launching a local Zeppelin Notebook Docker container that connects to an AWS Glue Development Endpoint. This allows you to author and test your Glue ETL scripts.

## Table of Contents
- [Notes](#notes)
- [SSH Keys](#ssh-keys)
- [Deployment](#deployment)
- [Revision History](#revision-history)

## Notes

Currently the only base OS is for Amazon Linux 2. Alpine is the next OS on the roadmap.

As of 7/1/19, Glue only supports Zeppelin version 0.7.X and lower. These versions of Zeppelin only support plain-text passwords in the shiro.ini file and do not support hashed passwords which are available in version 0.8.X and higher.

The container only includes the Spark interpreter in order to minimize size.

SSL is disabled on the container for the web interface. You can update the `zeppelin-site.xml` file to enable SSL and specify an SSL certificate. You might want to add a volume mount in the docker-compose file with the SSL certificate that is stored locally.

## SSH Keys

You have two choices for connecting securely to the Glue Dev Endpoint via SSH from the container. 

1) Create the public/private keys locally and supply the public key during the endpoint creation process. Supply the path to the private key as a volume mount in the `docker-compose.yaml` file, replacing the path `/Users/mhaken/.ssh/id_rsa` with the actual path to the pem file private key. Do not modify the ':/ssh/glue.pem' part of the volume mount.
2) Create the endpoint without an SSH key defined. Deploy the container without specifying a volume pointing at a private key (delete the "volumes" parameter). The container will generate a key pair, write the public key to stdout and terminate. Copy the public key from stdout and add it to the AWS Glue development endpoint definition. Start the container again. This key will only last the lifetime of the container.

## Deployment

1) Build the docker container with the `build.ps1` script. Once the container has been built or downloaded from a repo, update the `docker-compose.yaml` file. 

2) Replace the `<password>` with one of your choosing that will be used to log in to the notebook.

3) Update the `ec2-1-2-3-4.compute-1.amazonaws.com` Development Endpoint domain name with the actual name of your endpoint.

4) Follow the instructions [above](#ssh-keys) for configuring the SSH keys.

5) Start the container, `docker run zeppelin`.

## Revision History

### 1.0.0
Initial Release