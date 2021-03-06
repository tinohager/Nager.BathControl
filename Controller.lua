dofile("Humidity.lua")
dofile("Webserver.lua")
--dofile("Dnsserver.lua")
dofile("Wifi.lua")

--gpio
dhtpin = 5
relaypin = 6
fanpin = 7

--fan
fanState = 0
fanLastRun = 0
fanTimeout = 30

----humidity sensor
sensorState = "unknown"
dhttemp = 0
dhthum = 0

--humidity 	threshold
logichumtreshold = 70
logichumhysteresis = 5

--wlan password for accesspoint
wlanpassword = "password"

--default dns answer
--captive portal‏ the same as setip->ip
dns_ip = "\192\168\230\1"

function startSystem()
	print('start controller')

	initGpio()
	setLight(1)

	rtctime.set(0)

	print('start wifi')
	wifi.setphymode(wifi.PHYMODE_B)
	wifi.setmode(wifi.STATION)
	wifi.sta.sethostname("bath")
	wifi.sta.config('ssid', 'password')

	print('start webserver')
	startWebserver()
	--print('start dnsserver')
	--startDnsServer();

	tmr.delay(2000000)
	
	setLight(0)
	
	tmr.alarm(1, 2000, tmr.ALARM_AUTO, function() readDht() end)
	tmr.alarm(2, 5000, tmr.ALARM_AUTO, function() logic() end)
end

startSystem()
