# iconv-nginx-module

include $(dir $(abspath $(lastword $(MAKEFILE_LIST))))/version
ICONV_NGINX_MODULE_URL :=	$(GITHUB)/calio/iconv-nginx-module/archive/v$(ICONV_NGINX_MODULE_VERSION).tar.gz

$(TARBALLS)/iconv-nginx-module-$(ICONV_NGINX_MODULE_VERSION).tar.gz:
	$(call download_pkg,$(ICONV_NGINX_MODULE_URL),iconv-nginx-module)

.sum-iconv-nginx-module:	iconv-nginx-module-$(ICONV_NGINX_MODULE_VERSION).tar.gz

iconv-nginx-module:	iconv-nginx-module-$(ICONV_NGINX_MODULE_VERSION).tar.gz .sum-iconv-nginx-module
	$(UNPACK)
	$(MOVE)

.iconv-nginx-module:	iconv-nginx-module
	touch $@
