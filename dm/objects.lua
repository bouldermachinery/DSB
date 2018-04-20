-- CSB buttons don't use click_to
for o in pairs(obj) do
	obj[o].click_to = nil
end

obj.floortext.no_party_triggerable = true