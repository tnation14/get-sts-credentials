FROM node:6.10

RUN set -ex \
	&& apt-get update -y \
	&& apt-get install -yq \
		build-essential \
		python \
		python-pip \
	&& pip install --upgrade pip \
	&& apt-get purge -y build-essential \
	&& rm -rf /var/lib/apt/lists/* \
	&& yarn global add serverless \
	&& mkdir -p /opt/pinkmoon-lambda-function

WORKDIR /opt/pinkmoon-lambda-function

COPY requirements.txt .

RUN pip install -r requirements.txt

ENTRYPOINT ["yarn"]