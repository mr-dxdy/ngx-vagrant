VERSION=1.0.1

build:
	docker build . --no-cache --tag mrdxdy/ngx-vagrant:${VERSION}

cache_build:
	docker build . --tag mrdxdy/ngx-vagrant:${VERSION}

publish:
	docker push mrdxdy/ngx-vagrant:${VERSION}
