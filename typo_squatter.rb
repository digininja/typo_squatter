#!/usr/bin/env ruby

# There is a problem here, as this is a hash it can't have the same source 
# character twice so you can't ask it to replace i with 1 and i with l
replace_hash = {
				"o" => "0",
				"i" => "l",
				"m" => "rn",
				"g" => "q",
				"q" => "g",
			}

if ARGV.length != 1
	puts "type_squatter v0.1

Usage: 
./typo_squatter.rb <domain name>

"
	exit 1
end

tmp_domain = ARGV.shift

domain_name = ""
if tmp_domain.match(/([^\.]*)[.](.*)/)
	domain_name = $1
	tld = $2
else
	domain_name = tmp_domain
	tld = nil
end

new_domains = []
num_replace = domain_name.length

0.upto((2**num_replace) - 1) do |bitmap|
	new_domain_name = domain_name.dup

	0.upto(num_replace - 1) do |bit|
		# Doing it with 0 rather than 1 because that runs through backwards
		# which means a 2 char replace happens at the end of the string first
		# and doesn't mess up the length of the string
		if bitmap[bit] == 0
			src_char = domain_name[bit]
			src_2_char = domain_name[bit, 2]

#			puts "bit = " + bit.to_s
#			puts "src = " + src_char
			#print domain_name[bit] + " "
			#print "replace "
			if replace_hash.has_key?(src_char)
				dst_char = replace_hash[src_char]
#				puts "dst = " + dst_char
				new_domain_name[bit, src_char.length] = dst_char
			elsif replace_hash.has_key?(src_2_char)
				dst_char = replace_hash[src_2_char]
#				puts "replacing " +bit.to_s + " with " + dst_char
#				puts "dst = " + dst_char
				new_domain_name[bit, src_2_char.length] = dst_char
			end
		else
	#		print "leave "
		end
	end
	if !(new_domains.include?(new_domain_name.to_s)) and domain_name != new_domain_name
		new_domains << new_domain_name
	end
end

if new_domains.count == 0
	puts "No suggestions of alternative domains"
else
	puts "Some alternative domains:"
	new_domains.each do |dom|
		if tld.nil?
			puts dom
		else
			puts dom + "." + tld
		end
	end
end
