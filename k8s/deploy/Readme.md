## 基于Gitlab+Jenkins Pipeline+Docker+Kubernetes+Helm的自动化部署

参考： [Kubernetes笔记（三）：Gitlab+Jenkins+k8s+Helm自动化部署实践（干货！）](http://blog.jboost.cn/k8s3-cd.html)

## Spring Boot项目配置需调整的地方

### 1. Dockerfile

```
EXPOSE 8000 #替换为您应用的端口

COPY ./target/your-project-name-1.0-SNAPSHOT.jar ./app.jar #替换为您应用的jar名称
```

### 2. helm/Chart.yaml

```
name: your-project-name #替换为您应用的名称
```

### 3. helm/values.yaml

```
imagePullSecrets:
  - name: aliyun-registry-secret #替换为您的名称

container:
  port: 8000  #替换为您应用的端口

service:
  type: NodePort
  port: 8000 #替换为您应用的端口
```

这里的secrets创建参考

```shell
# 登录Docker Registry生成/root/.docker/config.json文件
sudo docker login --username=your-username registry.cn-shenzhen.aliyuncs.com
# 创建namespace develop（我这里是根据项目的环境分支名称建立namespace）
kubectl create namespace develop
# 在namespace develop中创建一个secret
kubectl create secret generic aliyun-registry-secret --from-file=.dockerconfigjson=/root/.docker/config.json  --type=kubernetes.io/dockerconfigjson --namespace=develop
```

每一个namespace都需要创建一遍。

### 4. Jenkinsfile

```
 //docker registry凭证，替换为您的凭证名称
DOCKER_REGISTER_CREDS = credentials('aliyun-docker-repo-creds')
//开发测试环境kube凭证，替换为您的凭证名称
KUBE_CONFIG_LOCAL = credentials('local-k8s-kube-config')
//生产环境的kube凭证，替换为您的凭证名称
KUBE_CONFIG_PROD = "" //credentials('prod-k8s-kube-config')

//替换为您的Docker仓库地址与命名空间
DOCKER_REGISTRY = "registry.cn-hangzhou.aliyuncs.com" 
DOCKER_NAMESPACE = "your-namespace"

//替换为您的相应域名
INGRESS_HOST_DEV = "dev.your-site.com"    //开发环境的域名
INGRESS_HOST_TEST = "test.your-site.com"  //测试环境的域名
INGRESS_HOST_PROD = "prod.your-site.com"  //生产环境的域名

//替换为您服务的上下文路径
string(name: 'ingress_path', defaultValue: '/your-path', description: '服务上下文路径')
```

### 5. 其它

- 分支名称可根据实际情况调整
- 其它默认逻辑，如镜像tag名称等根据需要调整


## Vue.js Web项目配置需调整的地方

将当前vue-nginx目录下的所有文件复制到项目根路径下。

### 1. Dockerfile

基本不用调整，可将维护者改为您的名称

### 2. helm相关

参考Spring Boot部分的2,3

### 3. Jenkinsfile

使用Npm Build替换Maven Build，其它基本不变，相关调整参考Spring Boot的第4部分

### 4. nginx/default.conf

```conf
	#替换为您的路径
    location /your-path {
        alias /usr/share/nginx/html;
        index index.html index.htm;
        try_files  $uri $uri/ /index.html last;
    }
```


---

作者：雨歌  
请关注作者微信公众号：半路雨歌，支持作者持续创作，一起学习成长  
![微信公众号](http://blog.jboost.cn/assets/qrcode-05.jpg)