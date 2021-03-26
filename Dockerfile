ARG PYTHON_VERSION_FULL=3.9.2
# COPY commandで↓を使う正規表現で抽出した値をCOPY commandのargに渡す方法は見当たらなかった
ARG PYTHON_VERSION_MINOR=3.9
# lauのpyarrowは3.9で動かない
# https://github.com/apache/arrow/pull/8386

# ステージ分割参考
# https://future-architect.github.io/articles/20200513/
#####
FROM python:${PYTHON_VERSION_FULL}-buster as builder

WORKDIR /opt/app

COPY pyproject.toml ./
COPY poetry.lock ./

RUN set ex \
  # install except myself to increase cache efficiency
  && touch poetry_dummy.py \
  && pip install toml==0.10.2 \
  && mv pyproject.toml pyproject.bk.toml \
  && python -c "import toml; fr=open('pyproject.bk.toml', 'r'); fw=open('pyproject.toml', 'w'); d=toml.load(fr); d['tool']['poetry']['packages']=[{'include': 'poetry_dummy.py'}];  toml.dump(d, fw); fr.close(); fw.close();" \
;
RUN set ex \
  # print for debug
  && cat pyproject.toml \
  && pip install . \
;

#####
FROM python:${PYTHON_VERSION_FULL}-slim-buster as runner
ARG PYTHON_VERSION_MINOR
COPY --from=builder /usr/local/lib/python${PYTHON_VERSION_MINOR}/site-packages /usr/local/lib/python${PYTHON_VERSION_MINOR}/site-packages

RUN set -ex && apt-get update -yqq && apt-get upgrade -yqq && apt-get install -y \
  git \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && pip install --upgrade pip \
;

WORKDIR /app
COPY pyproject.toml ./
COPY poetry.lock ./
COPY src ./src

RUN pip install --no-cache-dir .
WORKDIR /app/src

# ENTRYPOINT ["python", "-m", "bayesian-ab"]
# CMD ["arg1", "arg2"]
