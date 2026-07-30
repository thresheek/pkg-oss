# openresty-test-nginx

OPENRESTY_TEST_NGINX_URL := https://github.com/openresty/test-nginx

PKGS += openresty-test-nginx

$(TARBALLS)/openresty-test-nginx:
	git clone $(OPENRESTY_TEST_NGINX_URL) $@

.sum-openresty-test-nginx: openresty-test-nginx ;

clean: clean-openresty-test-nginx

clean-openresty-test-nginx:
	$(RM) -R $(TARBALLS)/openresty-test-nginx
