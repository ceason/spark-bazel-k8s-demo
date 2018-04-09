

```
mkdir -p $HOME/.minikube
sudo ln -s $HOME/.minikube /root/.minikube
```

```
sudo apt install socat
```

```
wget https://github.com/kubernetes/minikube/releases/download/v0.25.2/minikube_0.25-2.deb
sudo dpkg -i minikube_0.25-2.deb
```


```
sudo -E minikube start --vm-driver=none --apiserver-ips=127.0.0.1 --apiserver-name=localhost --extra-config=apiserver.Authorization.Mode=RBAC
```

```
sudo minikube addons enable registry
```

```
kubectl --context=minikube apply -f docs/minikube-rbac.yaml
```

> To fix `minikube: Failed to stop localkube\x2c.service`
> see https://github.com/kubernetes/minikube/issues/2549#issuecomment-373956259

```
export IMAGE_CHROOT=localhost:30001/
```

