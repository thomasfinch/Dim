THEOS_PACKAGE_DIR_NAME = debs
TARGET =: clang
ARCHS = armv7 arm64
DEBUG = 1

include theos/makefiles/common.mk

TWEAK_NAME = Dim
Dim_FILES = Tweak.xm DimWindow.xm
Dim_FRAMEWORKS = UIKit
Dim_PRIVATE_FRAMEWORKS = GraphicsServices
Dim_LIBRARIES = flipswitch activator

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += switch
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 backboardd"
