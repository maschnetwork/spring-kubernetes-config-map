## Spring Cloud Kubernetes ConfigMap

This repository integrates with Spring-Cloud-Kubernetes-Config, which allows to change the Spring-Configuration during runtime. It can be therefore
be used as a simple Feature-Flag mechanism to enable and disable certain features during runtime.

### How to use this repo

This repository contains everything that you need to run the app locally with [minikube](https://minikube.sigs.k8s.io/docs/start/).

After cloning the project just run:

```shell script
./deploy.sh
```

## Overview

### Dependencies

Include the following libraries in your pom.xml and make sure that you your the proper BOM for Spring-Cloud dependency management.

```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.cloud</groupId>
        <artifactId>spring-cloud-starter-kubernetes-config</artifactId>
    </dependency>
</dependencies>

<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-dependencies</artifactId>
            <version>Hoxton.SR8</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>
```

###Kubernetes Resources

To be able to consume the Kubernetes ConfigMap resources you have to create a proper
RoleBinding:

```yaml
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: view-binding
  namespace: default
subjects:
  - kind: ServiceAccount
    name: default
    apiGroup: ""
roleRef:
  kind: ClusterRole
  name: view
  apiGroup: ""
```

The ConfigMap itself may look like this:


```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: "my-service-toggles"
data:
  application.yaml: |-
    feature-toggle:
      limit: 3000
      camel-case: true

```


### Bootstrap Yaml

Spring Cloud properties are read during startup via bootstrap.yaml. You 
have to provide the ConfigMap name here.

```yaml
spring:
  cloud:
    kubernetes:
      reload:
        enabled: true
        #If this is not working due to some network issues use "polling" instead
        mode: event
        strategy: refresh
      config:
        name: my-service-toggles
---
spring:
  #Disable for Testing
  profiles: test
  cloud:
    kubernetes:
      config:
        enabled: false
```

###Spring Configuration

To access the properties of the ConfigMap you can use a @ConfigurationProperties
annotation with a prefix to separate it from the rest of your configuration.

```kotlin
@Configuration
@ConfigurationProperties(prefix = "feature-toggle")
class FeatureToggleConfiguration {

    var limit: Int = 1000
    var camelCase: Boolean = false
    var test: String = "Hallo Static"

}
```

###Gotchas

- Your Spring Cloud configuration needs to be put inside configuration yaml (See Disabling the Spring Cloud Kubernetes Property for the test profile above).
- For some unknown reasons `mode: event` in bootstrap.yaml doesn't work properly and does not trigger a Configuration change. You can use `mode: polling`
which is less efficient but polls (per default) every 15s the latest state of the ConfigMap.





