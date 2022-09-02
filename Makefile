VERSION=1.0.0

build:
	docker build . --no-cache --tag mrdxdy/ngx-vagrant:${VERSION}

publish:
	docker push mrdxdy/ngx-vagrant:${VERSION}
