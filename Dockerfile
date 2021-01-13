FROM ubuntu:18.04

ARG SPARK_VERSION="spark-2.4.7-bin-hadoop2.7"

RUN groupadd --gid 1001 jupyter
RUN useradd --create-home --uid 1000 --gid 1001 jupyter
WORKDIR /home/jupyter

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -y && \
    apt-get install -y \
      build-essential \
      wget \
      openjdk-8-jdk
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre
ENV PATH="${JAVA_HOME}/bin:${PATH}"
COPY ./run_jupyter.sh ./run_jupyter.sh
RUN chmod +x ./run_jupyter.sh
USER jupyter
RUN wget -nv "https://apache.osuosl.org/spark/spark-2.4.7/${SPARK_VERSION}.tgz" && \
    mkdir spark && \
    tar -zxvf "${SPARK_VERSION}.tgz" -C spark/ && \
    rm -f "./${SPARK_VERSION}.tgz"
COPY ./spark-defaults.conf "./spark/${SPARK_VERSION}/conf/spark-defaults.conf"
ENV SPARK_HOME="/home/jupyter/spark/${SPARK_VERSION}"
ENV PATH="${SPARK_HOME}/bin:${PATH}"
ENV PATH="/home/jupyter/miniconda3/bin:${PATH}"
ENV PYLIB="${SPARK_HOME}/python/lib"
ENV PYTHONPATH="${SPARK_HOME}/python:${PYLIB}/py4j-0.9-src.zip:${PYLIB}/pyspark.zip:${PYTHONPATH}"
ENV PYSPARK_DRIVER_PYTHON="/home/jupyter/miniconda3/envs/pyspark/bin/python"
ENV PYSPARK_PYTHON="/home/jupyter/miniconda3/envs/pyspark/bin/python"
RUN wget -nv https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O conda_installer.sh && \
    chmod +x conda_installer.sh && \
    ./conda_installer.sh -b && \
    rm -f ./conda_installer.sh && \
    conda init && \
    . /home/jupyter/miniconda3/etc/profile.d/conda.sh && \
    conda activate base && \
    conda install -y -c conda-forge jupyterlab && \
    pip install toree && \
    jupyter toree install \
    --interpreters=Scala,SQL \
    --spark_home="${SPARK_HOME}" \
    --user \
    --kernel_name="Spark" \
    --toree_opts="--nosparkcontext" && \
    conda create -y --name pyspark python=3.7  && \
    conda activate pyspark && \
    conda install -y py4j ipykernel && \
    python -m ipykernel install --user --name=PySpark
EXPOSE 8888
CMD ["./run_jupyter.sh"]
