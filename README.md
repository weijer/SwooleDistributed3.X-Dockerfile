# 简介

strack框架的Dockerfile文件

# 框架版本

strack 1.0 

# 环境

## PHP版本

7.4

## PHP扩展

1. redis 4.3.0
1. swoole 4.0.4

# Docker运行

```
docker run -d -it --name sd_docker \
         -p 18119:80 \
        -v/mnt/hgfs/teamones:/usr/local/apache2/htdocs/app \ # 映射到本地磁盘
        weijer/sd_docker:alpine
```




