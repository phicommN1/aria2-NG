FROM alpine

# Install packages
RUN apk --no-cache add curl

# Copy scripts
COPY update-bt-tracker.sh /
COPY crontab /var/spool/cron/crontabs/root

# Give execution rights on the cron job
RUN chmod 0644 /var/spool/cron/crontabs/root

# Entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/bin/sh", "/entrypoint.sh"]

	
	ARG ARIANG_VERSION=1.0.0
	
	#ENV RPC_SECRET=secret 是否启用加密
	ENV RPC_SECRET=""
	ENV DOMAIN=0.0.0.0:6880
	ENV PUID=0
	ENV PGID=0
	
	RUN apk update \
	&& apk add --no-cache --update caddy curl aria2 su-exec
	
	# AriaNG
	WORKDIR /usr/local/www/aria2
	
	RUN curl -sL https://github.com/mayswind/AriaNg/releases/download/${ARIANG_VERSION}/AriaNg-${ARIANG_VERSION}.zip \
	--output ariang.zip \
	&& unzip ariang.zip \
	&& rm ariang.zip \
	&& chmod -R 755 ./
	
	WORKDIR /aria2
	
	COPY conf ./conf-copy
	COPY aria2c.sh ./
	COPY Caddyfile /usr/local/caddy/
	
	RUN chmod +x aria2c.sh
	
	# User downloaded files
	VOLUME /aria2/data
	VOLUME /aria2/conf
	
	EXPOSE 6800
	EXPOSE 6880
	
	CMD ["/bin/sh", "./aria2c.sh" ]
