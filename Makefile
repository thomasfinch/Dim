ARCHS = armv7 arm64
THEOS_PACKAGE_DIR_NAME = debs
# PACKAGE_VERSION = 1.4

include theos/makefiles/common.mk

SOURCE_FILES=$(wildcard tweak/*.m tweak/*.mm tweak/*.x tweak/*.xm)

TWEAK_NAME = Dim
Dim_FILES = $(SOURCE_FILES)
Dim_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += switch
SUBPROJECTS += preferences
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard"