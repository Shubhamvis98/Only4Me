#!/bin/bash

case $1 in
	normal)
		echo 'Portrait'
		xrandr -o normal
		xinput set-prop 'pointer:Goodix Capacitive TouchScreen' 'Coordinate Transformation Matrix' 1 0 0 0 1 0 0 0 1
		;;
	inverted)
		echo 'Portrait Invert'
		xrandr -o inverted
		xinput set-prop 'pointer:Goodix Capacitive TouchScreen' 'Coordinate Transformation Matrix' -1 0 1 0 -1 1 0 0 1
		;;
	right)
		echo 'Landscape'
		xrandr -o right
		xinput set-prop 'pointer:Goodix Capacitive TouchScreen' 'Coordinate Transformation Matrix' 0 1 0 -1 0 1 0 0 1
		;;
	left)
		echo 'Landscape Invert'
		xrandr -o left
		xinput set-prop 'pointer:Goodix Capacitive TouchScreen' 'Coordinate Transformation Matrix' 0 -1 1 1 0 0 0 0 1
		;;
esac

