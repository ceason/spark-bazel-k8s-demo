

```
mkdir -p $HOME/.minikube
sudo ln -s $HOME/.minikube /root/.minikube
```

```
wget https://github.com/kubernetes/minikube/releases/download/v0.25.2/minikube_0.25-2.deb
sudo dpkg -i minikube_0.25-2.deb
```


```
sudo -E minikube start --vm-driver=none --apiserver-ips=127.0.0.1 --apiserver-name=localhost
```

```
sudo minikube addons enable registry
```

> To fix `minikube: Failed to stop localkube\x2c.service`
> see https://github.com/kubernetes/minikube/issues/2549#issuecomment-373956259

```
export IMAGE_CHROOT=localhost:30001/
```

```
cat <<EOF | kubectl --context=minikube apply -f -
apiVersion: v1
kind: Service
metadata:
  name: registry-nodeport
  namespace: kube-system
spec:
  type: NodePort
  ports:
  - port: 80
    targetPort: 5000
    nodePort: 30001
  selector:
    kubernetes.io/minikube-addons: registry
EOF
```