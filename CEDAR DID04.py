#!/usr/bin/python

import serial

dev = '/dev/ttyUSB0'
speed = 19200


s = serial.Serial(dev, speed)

while (s.read(1) != '\x18'):
    pass

while True:
    reading = s.read(6)
    # '+ 0.07'
    # '- 9.27'
    # '+13.84'

    sign = reading[0]
    mag = float(reading[1:])

    if sign != '+' and sign != '-':
        print 'Error: unexpected sign: %s' % (sign)
        break

    terminator = s.read(2)
    if terminator != '\r\x18':
        print 'Error: unexpected end reading: %s' % terminator.encode('hex')
        break


    print '%s%f' % (sign, mag)


