# Sample k8s webapp

Sample web application which will store and display the number of requests previously received.
MySQL will be used as a database, Django for the webserver with Varnish at the front.
The following requires a kubernetes cluster and kubectl configured. (https://kubernetes.io/docs/tasks/tools/install-kubectl/)

We will be using a namespace called dev :
```
kubectl apply -f namespace.yml
```

## MySQL

First we will create a secret for MySQL and provide it in command line for dev purposes. Let's generate one with openssl.
```
openssl rand -base64 16
kubectl create secret generic mysql-pass --from-literal=password=< my_secret > -n dev
```

Then, let's deploy the MySQL service in the dev namespace. The pod will be listening on 3306.
```
kubectl apply -n dev -f mysql-deployment.yml
```

## Django

We will first create some secrets for a new MySQL user and for the django app.

```
openssl rand -base64 16
kubectl create secret generic django-db-pass --from-literal=password=< my_new_secret > -n dev

openssl rand -base64 16
kubectl create secret generic django-secret-key --from-literal=key=< my_other_secret > -n dev
```

The Django docker image is generated with the Dockerfile here : https://github.com/camuzard/django-request-counter-docker

Gunnicorn is deployed on top of django and will be listening on 8000.

```
kubectl apply -n dev -f django-deployment.yml
```

## Varnish

Varnish will be listening on 80 and will be using django as backend. The varnish default vcl file will be provided to kubernetes as a configmap.

```
kubectl create configmap varnish-vcl --from-file=default.vcl -n dev
kubectl apply -n dev -f varnish-deployment.yml
```

Then, we use an external load balancer to have a public access (This feature is only available if your cloud provider or environment supports external load balancers).
```
kubectl apply -n dev -f lb.yml
```
