ARCHS = armv7 arm64
THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222
THEOS_BUILD_DIR = debs
GO_EASY_ON_ME = 1

include theos/makefiles/common.mk

TWEAK_NAME = Dim
Dim_FILES = Tweak.xm
Dim_FRAMEWORKS = UIKit
Dim_PRIVATE_FRAMEWORKS = GraphicsServices
Dim_LIBRARIES = flipswitch activator

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += switch
include $(THEOS_MAKE_PATH)/aggregate.mk
