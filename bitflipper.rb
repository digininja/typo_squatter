#!/usr/bin/env ruby

if ARGV.length != 1
	puts "bitflipper v0.1

Usage: 
./bitflipper.rb <domain name>

"
	exit 1
end

tmp_domain = ARGV.shift

domain_name = ""
if tmp_domain.match(/([^\.]*)\.(.*)/)
	domain_name = $1
	tld = $2
else
	domain_name = tmp_domain
	tld = nil
end

new_domains = []

pos = 0
domain_name.each_char do |a|
	0.upto(7) do |i|
		flipped = a.ord ^ (1 << i)
		if (flipped >= 48 and flipped <= 57) or (flipped >= 65 and flipped <= 90) or (flipped >= 97 and flipped <= 122)
			# Have to duplicate the string as strings work by reference
			new_str = domain_name.dup
			new_str[pos] = flipped.chr.downcase
			if !new_domains.include?(new_str)
				new_domains << new_str
			end
		end
	end
	pos += 1
end

new_domains.sort!

if new_domains.count == 0
	puts "No suggestions of bit flipped domains"
else
	puts "Some bit flipped domains:"
	new_domains.each do |dom|
		if tld.nil?
			puts dom
		else
			puts dom + "." + tld
		end
	end
end
