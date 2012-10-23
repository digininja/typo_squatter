#!/usr/bin/env ruby

# == Typo Squater - suggest alternative domains
#
# Blah blah
#
# See the README for full information
#
# Author:: Robin Wood (robin.wood@randomstorm.com)
# Version:: 1.0
# Copyright:: Copyright(c) 2012, RandomStorm Limited - www.randomstorm.com
# Licence:: Creative Commons Attribution-Share Alike 2.0
#
# Changes:
# 1.0 - Released
#

require 'getoptlong'
require 'whois'

# The left hand character is what you are looking for
# and the right hand one is the one you are replacing it
# with

leet_swap = {
			"l" => "i",
			"m" => "rn",
			"o" => "0",
			"i" => "l",
			}

opts = GetoptLong.new(
	[ '--help', '-h', GetoptLong::NO_ARGUMENT ],
	[ '--verbose', "-v" , GetoptLong::NO_ARGUMENT ]
)

# Display the usage
def usage
	puts "typo_squater v 1.0 Robin Wood (robin@digininja.org) <www.digininja.org>

Usage: typo_squater.rb [OPTION] <DOMAIN>
	--help, -h: show help
	--verbose, -v: verbose

"
	exit
end

def binaryincrement(binarray)
	index = binarray.size-1
	incremented = false
	 while !incremented and index>=0
		if (binarray[index]==0)
			binarray[index] = 1
			incremented = true
			break
		else
			binarray[index]=0
		end
		index -= 1
	end
	return binarray
end

def leet_variations(word, swap_array)
	count = 0
	swap_array.keys.each do |key|
		count += word.count(key)
	end

	variation = Array.new(count,0)
	leetletterpos = Array.new(count,0)
	variationarr = []
	# Save the indexes where the leet letters can be substituted
	pos = 0
	iter = 0
	tmpword = word.dup

	swap_array.each do |char, replace|
		pos = 0
		while (!(pos=tmpword.index(char)).nil?)
			leetletterpos[iter] = pos
			tmpword[pos]="$"
			iter += 1
		end
	end
	# Create all posible combinations of subtitutions
	src_chars = swap_array.keys.join
	dst_chars = swap_array.values.join

	begin
		tmpword = word.dup
		variation = binaryincrement(variation)
		idx = 0
		variation.each{|changeletter|
			if (changeletter==1)
				# Tried tr! but it won't replace inline, probably because it doesn't know where the slice is happening
				#tmpword[leetletterpos[idx],1] = tmpword[leetletterpos[idx],1].tr(src_chars, dst_chars)
				swap_array.each_pair do |src, dst|
					tmpword[leetletterpos[idx],1] = tmpword[leetletterpos[idx],1].sub(/#{Regexp.quote(src)}/, dst)
				end
			end
			idx += 1
		}
		variationarr << tmpword
	end while (variation != Array.new(count,1))
	return variationarr
end

verbose=false

begin
	opts.each do |opt, arg|
		case opt
		when '--help'
			usage
		when '--verbose'
			verbose=true
		end
	end
rescue => e
	puts e
	usage
end

if ARGV[0].nil?
	puts "No domain specified"
	puts
	usage
	exit
end

domain = ARGV[0]
tld=""

# Don't just take from the last dot as that would leave .co.uk as just uk
if domain.match(/^([^.]*)\.(.*$)/)
	name = $1
	tld = $2
end
if verbose
	puts "name = " + name
	puts "tld = " + tld
end

results = []

leetarr = leet_variations(name, leet_swap)
leetarr.each do |leetvar|
	results << leetvar + "." + tld
end

results.uniq!

results.each do |newdomain|
	who = nil
	begin
		who = Whois.query(newdomain)
	rescue
	end

	if (!who.nil?)
		puts newdomain + " - Registered"
	else
		puts newdomain + " - Unregistered"
	end
end
