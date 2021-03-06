function initGpio()
	gpio.mode(dhtpin, gpio.INPUT)
	gpio.mode(fanpin, gpio.OUTPUT)
	gpio.write(fanpin, gpio.LOW)
	gpio.mode(relaypin, gpio.OUTPUT)
	gpio.write(relaypin, gpio.LOW)	
end

function setLight(state)
	if (state == 1) then
		gpio.write(relaypin, gpio.HIGH)
	else
		gpio.write(relaypin, gpio.LOW)
	end
end

--dht is humidtySensor (use float firmware)
function readDht()
	status, temp, humi, temp_dec, humi_dec = dht.read(dhtpin)
	
	dhtstate = status
	if (status == dht.OK) then
		sensorState = "ready"
		dhttemp = temp
		dhthum = humi
		--print("read dht:" .. humi)
	elseif (status == dht.ERROR_CHECKSUM) then
		sensorState = "checksum error"
		print("DHT Checksum error.")
	elseif (status == dht.ERROR_TIMEOUT) then
		sensorState = "timeout"
		print("DHT timed out.")
	end
end

function setFan(state)
	if (state == 1) then
		local tempTime = rtctime.get()
		print("calc" .. fanLastRun + fanTimeout)
		print("tempTime:" .. tempTime)
		if (fanLastRun + fanTimeout < tempTime or fanLastRun == 0) then
			fanLastRun = tempTime
			fanState = 1
			gpio.write(fanpin, gpio.HIGH)
			gpio.write(relaypin, gpio.HIGH)
			print("start fan")
			return true
		else
			print("cannot start fan - wait")
			return false
		end
	else
		fanState = 0
		gpio.write(fanpin, gpio.LOW)
		gpio.write(relaypin, gpio.LOW)
		print("stop fan")
		return true
	end
end

function logic()
	if (sensorState ~= "ready") then
		print("logic disabled sensor not ready")
		return
	end
	if (dhthum > logichumtreshold) then
		if (fanState == 0) then
			print("hum high, start fan")
			setFan(1)
		end
	elseif (dhthum <= logichumtreshold-logichumhysteresis) then
		if (fanState == 1) then
			print("hum ok, stop fan")
			setFan(0)
		end
	end
end
