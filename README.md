## 应用服务发现组件发布文档    
##### bamboo组件json文件解析：        

```
{
    "cmd": null,
    "id": "cluster1-2048-bamboo",   //集群名称-应用名
    "cpus": 0.1,
    "mem": 512,
    "instances": 1,
    "constraints": [
        [
            "vcluster",
            "LIKE",
            "cluster1"    //集群名称
        ],
        [
            "hostname",
            "UNIQUE"
        ],
        [
            "hostname",
            "CLUSTER",
            "192.168.1.214"    //发布的目标主机
            ]
    ],
    "container": {
        "volumes": [
         {
            "hostPath": "/data/haproxy",
            "containerPath": "/etc/haproxy",
            "mode": "RW"
         }
        ],
        "docker": {
            "parameters": [],
            "network": "HOST",
            "portMappings": [],
            "image": "offlineregistry.dataman-inc.com:5000/library/omega-bamboo:omega.v3.0.4"
        }
    },
    "uris": [],
    "healthChecks": [
        {
            "port": 8000,    //健康检查的端口，和bamboo的监听端口一致
            "path": "/",
            "maxConsecutiveFailures": 3,
            "protocol": "TCP",
            "gracePeriodSeconds": 300,
            "intervalSeconds": 60,
            "timeoutSeconds": 30
        }
    ],
    "env": {
        "MARATHON_ENDPOINT": "http://192.168.1.213:8080",    //marathon地址，多个以逗号分隔
        "BAMBOO_ENDPOINT": "http://192.168.1.214:8000",    //bamboo发布IP:port
        "BAMBOO_ZK_HOST": "192.168.1.213:2181",    //zookeeper地址，多个以逗号分隔
        "MARATHON_USE_EVENT_STREAM": "true",
        "BAMBOO_ZK_PATH": "/bb_gateway",
        "HAPROXY_PORT": "5005",    //haproxy监听端口，需要与haproxy的json文件的监听端口一致
        "HAPROXY_UI_PORT": "5091",   //haproxy ui访问监听端口，haproxy的健康检查端口与此端口需要一致
        "APPLICATION_ID": "cluster1-2048",    //应用名称，需要和被服务发现的应用名称一致
        "BIND": ":8000",    //bamboo监听端口
        "CONFIG_PATH": "config/production.json"
    }
}    

注：此json文件不能直接复制粘贴使用，添加注释的需要根据实际情况进行替换，json文件放在：
/data/sry-deploy-app-tool/app_jsons/2048-bamboo.json
```

##### haproxy组件json文件解析：      
   

```

{
    "id": "cluster1-2048-haproxy",     //集群名称-应用名
    "cmd": null,
    "cpus": 0.1,
    "mem": 512,
    "instances": 1,
    "constraints": [
        [
            "vcluster",
            "LIKE",
            "cluster1"    //集群名称
        ],
        [
            "hostname",
            "UNIQUE"
        ],
        [
            "hostname",
            "CLUSTER",
            "192.168.1.214"    //发布的目标主机
        ]
    ],
    "container": {
        "volumes": [
         {
            "hostPath": "/data/haproxy/cluster1-2048",    //cluster1-2048应用id需要与被服务发现的应用名称以及bamboo配置的一致
            "containerPath": "/etc/haproxy",
            "mode": "RW"
         }
        ],
        "docker": {
            "parameters": [],
            "network": "HOST",
            "portMappings": [],
            "image": "offlineregistry.dataman-inc.com:5000/library/omega-haproxyctl:omega.v2.4.2"
        }
    },
    "uris": [],
    "healthChecks": [
        {
            "port": 5091,    //haproxy健康检查端口，与bamboo的haproxy_ui_port字段一致
            "maxConsecutiveFailures": 3,
            "protocol": "TCP",
            "gracePeriodSeconds": 300,
            "intervalSeconds": 60,
            "timeoutSeconds": 30
        }
    ],
    "env": {
        "BIND": "0.0.0.0:5005",    //haproxy监听端口，与bamboo的haproxy_port字段一致
	"CONFIG_PATH": "/config/production.json"
    }
}
注：此json文件不能直接复制粘贴使用，添加注释的需要根据实际情况进行替换，json文件放在：
/data/sry-deploy-app-tool/app_jsons/2048-haproxy.json    

```

##### 修改应用服务发现组件发布工具配置文件：    

```
vi /data/sry-deploy-app-tool/config.cfg
#!/bin/bash

BASE_URL=http://192.168.1.213:5013    #修改为实际的数人云平台登录地址
USERNAME="admin"							 #修改为实际的用户名
PASSWORD="Admin1234"					 #修改为实际的密码

```


##### 使用应用服务发现组件发布工具发布应用：    

```
1.准备好bamboo，haproxy，app发布的json文件
2.cd /data/sry-deploy-app-tool/
python deployApp.py -U http://192.168.1.213:5013 -B ./app_jsons/2048-bamboo.json -H ./app_jsons/2048-haproxy.json -A ./app_jsons/2048.json -M swan

命令行参数解析：
-U 数人云平台地址，baseurl
-B 指定bamboo json文件，可以指定多个，指定多个以逗号分隔，不指定则不进行bamboo的发布
-H 指定haproxy json文件，可以指定多个，指定多个以逗号分隔，不指定则不进行haproxy的发布
-A 指定发布的服务（比如2048等）json文件，可以指定多个，指定多个以逗号分隔，不指定则不发布
-M 指定发布swan|marathon版本的应用

```
