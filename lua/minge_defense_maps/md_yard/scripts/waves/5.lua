--this is included by the loader if the map is md_yard and wave 5 has started
--the file's name is what wave you want it to load on
--if a function is returned it will be used in place of the wave_generator's returned funciton
return function(wave)
	print("Custom wave code!")
end