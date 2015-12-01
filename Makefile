ARCHS = armv7 arm64
THEOS_PACKAGE_DIR_NAME = debs

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Dim
Dim_FILES = $(wildcard tweak/*.m tweak/*.mm tweak/*.x tweak/*.xm)
Dim_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += switch
SUBPROJECTS += preferences
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"