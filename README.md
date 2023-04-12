# nonoprint
simplified 3d printer usb daemon

This is a simple perl daemon that opens a usb serial port on a Marlin based 3d printer. It initializes the serial port. Then waits for a print to start, when it starts is pull a picture from mjpg-streamer everytime the Z axis changes. This will be ugly if you use z-hop. 

A simple command structure will be implemented to allow a few basic funtions. Like emergency stop. 
