#!/usr/bin/env ruby
require 'RMagick'
include Magick
require_relative 'CenterSearch.rb'
include CenterSearch

qr = Magick::QuantumRange / 1.0 # Convert to float

# Directory where screenshots are placed.
$scrots = "#{Dir.home}/documents/screenshots" # '$'=global

# Director where filtered screenshots are dumped.
$dump = "#{Dir.home}/documents/dump"
# Set some parameters.
$crop_width  = 640
$crop_height = 480
$tl_corner_X = 0
$tl_corner_Y = 0 # Alternatively, can use "gravity" argument of IM.

# Test if screenshot directory exists and is, in fact, a directory.
if test("d", $scrots)
  # Runs screenshotter in subshell. Moves to screenshot directory before running command.
  temp_pid = spawn("scrot", :chdir => $scrots)
  pid, status = Process.waitpid2(temp_pid) # Waits for process to finish.
  
  if status.exitstatus == 0 #Successful exit.
    puts "Command successfully run"
  else
    puts $? # Last error status as returned by bash.
    exit 1 # General exit error code.
  end
  
  # Get contents of screenshot directory as sorted array of strings.
  ss_listing = Dir.entries($scrots).sort
  puts last_ss = ss_listing.last # Save the last image string.
  
else
  puts "Directory given does not exist."
  exit 1 # General exit error code.
end

# Read the image using ImageMagick. Returns array, keep first index.
img = Image.read("#{$scrots}#{last_ss}").first
img.crop!(Magick::NorthWestGravity, $crop_width, $crop_height);
img = img.blur_image(2)

# Displays basic information about image being manipulated by IM.
puts "#{img.base_filename} has #{img.columns}x#{img.rows} pixels"

# Filters pixels and converts to grayscale. 
img.view(0, 0, img.columns, img.rows) do |view|
  view[][].each do |pixel|
    pixel.red = Math.exp((pixel.red/qr-0.231)**2/-0.0007)*0.85*qr
    pixel.green = Math.exp((pixel.green/qr-0.114)**2/-0.0002)*0.74*qr
    pixel.blue = Math.exp((pixel.blue/qr-0.099)**2/-0.0002)*0.95*qr

    pixel.red = pixel.blue = pixel.green = pixel.red * 0.3126 + pixel.green * 0.6152 + pixel.blue * 0.0722 # Custom grayscale conversion.
  end
end

# Stretch the image's histogram to fill quantum range.
img = img.auto_level_channel()

# Writes output image if directory exists.
if test("d", $dump)
  img.write("#{$dump}#{last_ss}")
else
  puts "Output directory doesn't exist. Not writing output image."
end

# Apply threshold to image to indicated pixels of interest.
img_threshold = img.threshold(qr*0.50) # 50% threshold

target_pixel = Pixel.new(qr, qr, qr, 0) # Opaque white

# Search array for target pixel.
aView = img_threshold.view(0, 0, img_threshold.columns, img_threshold.rows)
message, coord = search_2D(aView, img_threshold.columns, img_threshold.rows, target_pixel)

puts "Target pixel found at:"
p coord

exit 0