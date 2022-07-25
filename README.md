# kubernetes-logging

This setup provisions a sample [logging](https://github.com/nickytd/kubernetes-logging-helm) stack in a minikube/kind environment. The ingress definitions in the examples require cert-manager for ingress certificates.

# helm chart dependencies
* ```helm repo add nickytd https://nickytd.github.io/kubernetes-logging-helm```
* Ningx [ingress controller](https://github.com/nickytd/kubernetes-ingress-nginx)
* [Certificate manager](https://github.com/nickytd/kubernetes-cert-manager)
