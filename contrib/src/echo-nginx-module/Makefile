# echo-nginx-module

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
ECHO_NGINX_MODULE_URL :=	$(GITHUB)/openresty/echo-nginx-module/archive/v$(ECHO_NGINX_MODULE_VERSION).tar.gz

$(TARBALLS)/echo-nginx-module-$(ECHO_NGINX_MODULE_VERSION).tar.gz:
	$(call download_pkg,$(ECHO_NGINX_MODULE_URL),echo-nginx-module)

.sum-echo-nginx-module:	echo-nginx-module-$(ECHO_NGINX_MODULE_VERSION).tar.gz

echo-nginx-module:	echo-nginx-module-$(ECHO_NGINX_MODULE_VERSION).tar.gz .sum-echo-nginx-module
	$(UNPACK)
	$(MOVE)

.echo-nginx-module:	echo-nginx-module
	touch $@
