.PHONY: run build
run:
	xhost +local:docker
	docker run -it \
		-e DISPLAY=$(DISPLAY) \
		-e WAYLAND_DISPLAY=$(WAYLAND_DISPLAY) \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-v ./:/arch -w /arch arch:latest
build:
	docker build --output type=docker . -t arch:latest
