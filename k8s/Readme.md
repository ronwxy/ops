

## 配置nginx-ingress-controller运行在指定Node上

```shell
kubectl get nodes --show-labels  #查看Nodes，且显示标签

kubectl label node dev-server-2 nginx-ingress=true #给Node打标签
```