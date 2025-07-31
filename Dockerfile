# 使用官方 Python 3.12 镜像
FROM python:3.12

# 设置工作目录
WORKDIR /app

# 复制代码到容器内
COPY . /app

# 安装依赖（如果有requirements.txt）
RUN pip install --no-cache-dir -r requirements.txt

# 指定容器启动时执行的命令
CMD ["python", "main.py"]