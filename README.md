# 简介

SwooleDistributed框架的Dockerfile文件

# 框架版本

3.6.5 线上环境比较稳定版本

# 环境

## PHP版本

7.2.18

## PHP扩展

1. ds 1.2.4
1. redis 4.3.0
1. inotify 2.0.0
1. swoole 4.0.4

# Docker运行

```
docker run -d -it --name sd_docker \
        -p 19081:9081 \ # 映射端口
        -p 19082:9082 \
        -p 19083:9083 \
        -v /mnt/hgfs/dev/weijer/jgy_message:/home/server \ # 映射到本地磁盘
        weijer/sd_docker:latest
```




